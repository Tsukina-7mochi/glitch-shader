// Glitch effect shared by all passes.
//
// A glitch band moves along the object-space Y axis and pushes the mesh near it
// horizontally on screen. The band is evaluated in screen space, so the geometry stage
// slices triangles along the band boundaries (sliceTriangleByGlitch) to make it look
// right on low-poly meshes.
#ifndef GLITCH_SHADER_GLITCH_INCLUDED
#define GLITCH_SHADER_GLITCH_INCLUDED

#include "./Properties.hlsl"

// Interpolates a field of the three vertices v[0], v[1], v[2] with barycentric weights.
#define INTERPOLATE_TRIANGLE(v, weights, field) \
    (v[0].field * (weights).x + v[1].field * (weights).y + v[2].field * (weights).z)

#define GLITCH_OFFSCREEN 1e30

float screenY(float4 clipPos)
{
    return clipPos.y / clipPos.w;
}

//------------------------------------------------------------------------------
// Band

// Object-space Y coordinate of the center of a glitch band.
// The band moves from _GlitchMaxY to _GlitchMinY once every `period` seconds.
float glitchCenterY(float period)
{
    return (1 - frac(_Time.y / period)) * (_GlitchMaxY - _GlitchMinY) + _GlitchMinY;
}

// A glitch band projected on the screen (NDC Y, bottom <= center <= top).
struct GlitchBand
{
    float bottom;
    float center;
    float top;
};

// The band spans 1 / _GlitchSharpness above and below its center along the object-space Y axis.
GlitchBand getGlitchBand(float period)
{
    float centerY = glitchCenterY(period);
    float halfWidth = 1 / max(_GlitchSharpness, 1e-6);
    float4 lower  = UnityObjectToClipPos(float3(0, centerY - halfWidth, 0));
    float4 center = UnityObjectToClipPos(float3(0, centerY, 0));
    float4 upper  = UnityObjectToClipPos(float3(0, centerY + halfWidth, 0));

    GlitchBand band;
    if (min(min(lower.w, center.w), upper.w) <= 0)
    {
        // behind the camera: no screen position
        band.bottom = GLITCH_OFFSCREEN;
        band.center = GLITCH_OFFSCREEN;
        band.top    = GLITCH_OFFSCREEN;
    }
    else
    {
        band.bottom = min(screenY(lower), screenY(upper));
        band.center = screenY(center);
        band.top    = max(screenY(lower), screenY(upper));
    }
    return band;
}

// How strongly a band displaces a point at screen Y, in [0, 1].
// A tent function: 1 at the band center, 0 outside the band.
float glitchWeight(GlitchBand band, float y)
{
    float rise = (y - band.bottom) / max(band.center - band.bottom, 1e-6);
    float fall = (band.top - y) / max(band.top - band.center, 1e-6);
    return saturate(min(rise, fall));
}

//------------------------------------------------------------------------------
// Displacement

// Shifts a clip-space position horizontally on screen.
// The amounts are in view-space units, so the shift on screen shrinks with distance.
float4 applyGlitch(float4 clipPos)
{
    if (clipPos.w <= 0) return clipPos;

    float y = screenY(clipPos);
    float amount = glitchWeight(getGlitchBand(_GlitchPeriod1), y) * _GlitchDisplacement1
                 + glitchWeight(getGlitchBand(_GlitchPeriod2), y) * _GlitchDisplacement2;
    return clipPos + float4(amount * UNITY_MATRIX_P[0][0], 0, 0, 0);
}

//------------------------------------------------------------------------------
// Triangle slicing
//
// glitchWeight is linear in screen Y except at 3 heights per band (bottom, center, top).
// Cutting a triangle with horizontal screen lines at those heights ("cuts") puts a vertex
// wherever glitchWeight bends, so the displacement is exact at the cuts and approximately
// linear between them (the shift on screen also scales with 1 / w).
//
// The sliced triangle is emitted as one triangle strip that zigzags between its two sides:
//
//           p2              p0, p1, p2: vertices sorted by screen Y
//          /  \             S: points on the short side (p0 -> p1 -> p2)
//        L2 -- S2           L: points on the long side  (p0 -> p2)
//        /  ___/ p1
//      L1 -- S1             strip: p0, S1, L1, p1, L2, S2, p2
//      / ___/
//    p0
//
// p1 is an extra point on the short side, so the order of S and L swaps after it:
//   p0, (S, L) for each cut below p1, p1, (L, S) for each cut above p1, p2
//
// Each strip vertex is given as perspective-correct barycentric weights over the input
// triangle, so the pass can interpolate any vertex attribute with them.

#define GLITCH_CUT_COUNT 6
// p0 + (S, L) per cut + p1 + p2
#define GLITCH_SLICE_MAX_VERTEX_COUNT 15

struct GlitchSlice
{
    // clip-space W of the input vertices
    float3 w;
    // false if the triangle crosses the camera plane; such a triangle is emitted as is
    bool sliceable;

    // vertices sorted by screen Y: their screen Y coordinates and barycentric weights
    float y0, y1, y2;
    float3 p0, p1, p2;

    // cuts sorted by screen Y; cuts[firstCut] .. cuts[firstCut + cutCount - 1] cross the triangle
    float cuts[GLITCH_CUT_COUNT];
    uint firstCut;
    uint cutCount;
    uint cutCountBelowP1;

    uint vertexCount;
    // the strip winds like (p0, p1, p2); walk it backwards if that differs from the input
    bool reversed;
};

// Screen Y coordinates where glitchWeight bends, sorted in ascending order.
void getGlitchCuts(out float cuts[GLITCH_CUT_COUNT])
{
    GlitchBand band1 = getGlitchBand(_GlitchPeriod1);
    GlitchBand band2 = getGlitchBand(_GlitchPeriod2);
    cuts[0] = band1.bottom;
    cuts[1] = band1.center;
    cuts[2] = band1.top;
    cuts[3] = band2.bottom;
    cuts[4] = band2.center;
    cuts[5] = band2.top;

    // bubble sort
    [unroll]
    for (uint i = 0; i < GLITCH_CUT_COUNT - 1; i++)
    {
        [unroll]
        for (uint j = 0; j < GLITCH_CUT_COUNT - 1 - i; j++)
        {
            float a = cuts[j];
            float b = cuts[j + 1];
            cuts[j] = min(a, b);
            cuts[j + 1] = max(a, b);
        }
    }
}

// Slices a triangle given by the clip-space positions of its vertices.
GlitchSlice sliceTriangleByGlitch(float4 clip0, float4 clip1, float4 clip2)
{
    GlitchSlice s = (GlitchSlice)0;
    s.w = float3(clip0.w, clip1.w, clip2.w);
    s.sliceable = min(min(s.w.x, s.w.y), s.w.z) > 0;

    // sort the vertices by screen Y, tracking whether the winding flips
    float y0 = screenY(clip0), y1 = screenY(clip1), y2 = screenY(clip2);
    float3 p0 = float3(1, 0, 0), p1 = float3(0, 1, 0), p2 = float3(0, 0, 1);
    bool windingFlipped = false;
    float ty; float3 tp;
    if (y1 < y0) { ty = y0; y0 = y1; y1 = ty; tp = p0; p0 = p1; p1 = tp; windingFlipped = !windingFlipped; }
    if (y2 < y1) { ty = y1; y1 = y2; y2 = ty; tp = p1; p1 = p2; p2 = tp; windingFlipped = !windingFlipped; }
    if (y1 < y0) { ty = y0; y0 = y1; y1 = ty; tp = p0; p0 = p1; p1 = tp; windingFlipped = !windingFlipped; }
    s.y0 = y0; s.y1 = y1; s.y2 = y2;
    s.p0 = p0; s.p1 = p1; s.p2 = p2;
    s.reversed = windingFlipped;

    float cuts[GLITCH_CUT_COUNT];
    getGlitchCuts(cuts);
    s.cuts = cuts;

    if (s.sliceable)
    {
        [unroll]
        for (uint i = 0; i < GLITCH_CUT_COUNT; i++)
        {
            if (cuts[i] <= y0)
            {
                s.firstCut++;
            }
            else if (cuts[i] < y2)
            {
                s.cutCount++;
                if (cuts[i] < y1) s.cutCountBelowP1++;
            }
        }
    }

    s.vertexCount = 2 * s.cutCount + 3;
    return s;
}

// Point at screen Y on the short side (p0 -> p1 -> p2).
float3 shortSidePoint(GlitchSlice s, float y)
{
    if (y < s.y1) return lerp(s.p0, s.p1, (y - s.y0) / (s.y1 - s.y0));
    else          return lerp(s.p1, s.p2, (y - s.y1) / (s.y2 - s.y1));
}

// Point at screen Y on the long side (p0 -> p2).
float3 longSidePoint(GlitchSlice s, float y)
{
    return lerp(s.p0, s.p2, (y - s.y0) / (s.y2 - s.y0));
}

// Screen-space barycentric weights of the i-th strip vertex, in emission order.
float3 getScreenSliceWeights(GlitchSlice s, uint i)
{
    uint index = s.reversed ? s.vertexCount - 1 - i : i;
    uint p1Index = 1 + 2 * s.cutCountBelowP1;

    if (index == 0) return s.p0;
    if (index == s.vertexCount - 1) return s.p2;
    if (index == p1Index) return s.p1;

    // below p1: (S, L) per cut, above p1: (L, S) per cut
    bool belowP1 = index < p1Index;
    uint offset = belowP1 ? index - 1 : index - p1Index - 1;
    uint cut = s.firstCut + (belowP1 ? 0 : s.cutCountBelowP1) + offset / 2;
    bool isShortSide = (offset % 2 == 0) == belowP1;

    float y = s.cuts[cut];
    return isShortSide ? shortSidePoint(s, y) : longSidePoint(s, y);
}

// Perspective-correct barycentric weights of the i-th strip vertex, in emission order.
float3 getSliceWeights(GlitchSlice s, uint i)
{
    float3 screenWeights = getScreenSliceWeights(s, i);
    if (!s.sliceable) return screenWeights;

    float3 weights = screenWeights / s.w;
    return weights / (weights.x + weights.y + weights.z);
}

#endif // GLITCH_SHADER_GLITCH_INCLUDED
