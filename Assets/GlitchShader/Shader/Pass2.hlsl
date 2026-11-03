#include "UnityCG.cginc"
#include "./Properties.hlsl"
#include "./Util.hlsl"
#include "./Glitch.hlsl"

#ifndef _BgGrabTextureName
#error "_BgGrabTextureName undefined"
#endif

#ifndef _PrevPassGrabTextureName
#error "_PrevPassGrabTextureName undefined"
#endif

sampler2D _BgGrabTextureName;
sampler2D _PrevPassGrabTextureName;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 grabPosR : TEXCOORD1;
    float4 grabPosG : TEXCOORD2;
    float4 grabPosB : TEXCOORD3;
};

// Vertex stage

v2f vert(appdata v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f,o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    return o;
}

// Geometry stage

// Grab positions are computed in geom after the displacement.
v2f interpolateV2f(v2f v[3], float3 weights)
{
    v2f o = v[0];
    o.vertex = INTERPOLATE_TRIANGLE(v, weights, vertex);
    o.uv     = INTERPOLATE_TRIANGLE(v, weights, uv);
    return o;
}

// Slices the triangle along the glitch bands, then displaces every resulting vertex.
[maxvertexcount(GLITCH_SLICE_MAX_VERTEX_COUNT)]
void geom(triangle v2f input[3], inout TriangleStream<v2f> stream)
{
    GlitchSlice slice = sliceTriangleByGlitch(input[0].vertex, input[1].vertex, input[2].vertex);
    for (uint i = 0; i < slice.vertexCount; i++)
    {
        v2f o = interpolateV2f(input, getSliceWeights(slice, i));
        o.vertex = applyGlitch(o.vertex);

        // grab positions for chromatic aberration: G and B are sampled closer to the screen center than R
        float caMultiplier = 1 - _ChromaticAberrationIntensity;
        float4 clipPos = o.vertex;
        o.grabPosR = ComputeGrabScreenPos(clipPos);
        clipPos.xy *= caMultiplier;
        o.grabPosG = ComputeGrabScreenPos(clipPos);
        clipPos.xy *= caMultiplier;
        o.grabPosB = ComputeGrabScreenPos(clipPos);

        stream.Append(o);
    }
}

// Fragment stage

fixed4 frag (v2f i) : SV_Target
{
    fixed4 bgCol = tex2Dproj(_BgGrabTextureName, i.grabPosR);
    fixed colR = tex2Dproj(_PrevPassGrabTextureName, i.grabPosR).r;
    fixed colG = tex2Dproj(_PrevPassGrabTextureName, i.grabPosG).g;
    fixed colB = tex2Dproj(_PrevPassGrabTextureName, i.grabPosB).b;

    fixed4 texCol = tex2Dproj(_PrevPassGrabTextureName, i.grabPosR) * _Color;
    fixed brightness = maxElement(texCol.rgb);
    fixed4 col = lerp(
        bgCol,
        fixed4(colR, colG, colB, 1),
        saturate(pow(texCol.a, 1 - _AlphaCorrection * brightness))
    );

    return col;
}
