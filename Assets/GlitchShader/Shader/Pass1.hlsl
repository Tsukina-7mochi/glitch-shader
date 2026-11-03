#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "./OpenLitCore.hlsl"
#include "./Properties.hlsl"
#include "./Util.hlsl"
#include "./Glitch.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float3 normalOS : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 normalWS : TEXCOORD2;

    // [OpenLit] Add light datas
    #if defined(_PACK_LIGHTDATAS)
        nointerpolation uint3 lightDatas : TEXCOORD3;
        UNITY_FOG_COORDS(4)
        UNITY_LIGHTING_COORDS(5, 6)
        #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
            float3 vertexLight  : TEXCOORD7;
        #endif
    #else
        nointerpolation float3 lightDirection : TEXCOORD3;
        nointerpolation float3 directLight : TEXCOORD4;
        nointerpolation float3 indirectLight : TEXCOORD5;
        UNITY_FOG_COORDS(6)
        UNITY_LIGHTING_COORDS(7, 8)
        #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
            float3 vertexLight  : TEXCOORD9;
        #endif
    #endif
    UNITY_VERTEX_OUTPUT_STEREO
};

// Vertex stage

v2f vert(appdata v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f,o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.positionWS = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
    o.pos = UnityWorldToClipPos(o.positionWS);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normalWS = UnityObjectToWorldNormal(v.normalOS);
    UNITY_TRANSFER_LIGHTING(o,v.uv1);

    // [OpenLit] Calculate and copy vertex lighting
    #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH && defined(VERTEXLIGHT_ON)
        o.vertexLight = ComputeAdditionalLights(o.positionWS, o.pos) * _VertexLightStrength;
        o.vertexLight = min(o.vertexLight, _LightMaxLimit);
    #endif

    // [OpenLit] Calculate and copy light datas
    OpenLitLightDatas lightDatas;
    ComputeLights(lightDatas, _LightDirectionOverride);
    CorrectLights(lightDatas, _LightMinLimit, _LightMaxLimit, _MonochromeLighting, _AsUnlit);
    #if defined(_PACK_LIGHTDATAS)
        PackLightDatas(o.lightDatas, lightDatas);
    #else
        o.lightDirection = lightDatas.lightDirection;
        o.directLight = lightDatas.directLight;
        o.indirectLight = lightDatas.indirectLight;
    #endif

    return o;
}

// Geometry stage

// Light data (no interpolation), lighting coords (not written in this pass) and
// the stereo eye index are taken from v[0].
v2f interpolateV2f(v2f v[3], float3 weights)
{
    v2f o = v[0];
    o.pos        = INTERPOLATE_TRIANGLE(v, weights, pos);
    o.positionWS = INTERPOLATE_TRIANGLE(v, weights, positionWS);
    o.uv         = INTERPOLATE_TRIANGLE(v, weights, uv);
    o.normalWS   = INTERPOLATE_TRIANGLE(v, weights, normalWS);
    #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
        o.vertexLight = INTERPOLATE_TRIANGLE(v, weights, vertexLight);
    #endif
    return o;
}

// Slices the triangle along the glitch bands, then displaces every resulting vertex.
[maxvertexcount(GLITCH_SLICE_MAX_VERTEX_COUNT)]
void geom(triangle v2f input[3], inout TriangleStream<v2f> stream)
{
    // the glitch bands are projected with the matrices of this eye
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input[0]);

    GlitchSlice slice = sliceTriangleByGlitch(input[0].pos, input[1].pos, input[2].pos);
    for (uint i = 0; i < slice.vertexCount; i++)
    {
        v2f o = interpolateV2f(input, getSliceWeights(slice, i));
        o.pos = applyGlitch(o.pos);

        // fog depends only on the clip-space position
        UNITY_TRANSFER_FOG(o,o.pos);

        stream.Append(o);
    }
}

// Fragment stage

half4 frag(v2f i) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.positionWS);

    // [OpenLit] Copy light datas from the input
    OpenLitLightDatas lightDatas;
    #if defined(_PACK_LIGHTDATAS)
        UnpackLightDatas(lightDatas, i.lightDatas);
    #else
        lightDatas.lightDirection = i.lightDirection;
        lightDatas.directLight = i.directLight;
        lightDatas.indirectLight = i.indirectLight;
    #endif

    float3 N = normalize(i.normalWS);
    float3 L = lightDatas.lightDirection;
    float NdotL = dot(N,L);
    // float factor = NdotL > _ShadowThreshold ? 1 : 0;
    float factor = saturate(lerp(1, 0, (NdotL - _ShadowThreshold) / _ShadowBoundaryWidth));
    if(_ReceiveShadow) factor *= attenuation;

    half4 col = tex2D(_MainTex, i.uv) * _Color;
    half3 albedo = col.rgb;
    col.rgb *= lerp(1, _ShadowColor, factor);
    #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
        col.rgb += albedo.rgb * i.vertexLight;
        col.rgb = min(col.rgb, albedo.rgb * _LightMaxLimit);
    #endif
    UNITY_APPLY_FOG(i.fogCoord, col);

    col.rgb = maxElement(col.rgb);  // extract brightness
    col.rgb *= (sin(i.pos.y / _ScanLinePeriod) < 0) ? _ScanLineBrightness : 1;

    return col;
}
