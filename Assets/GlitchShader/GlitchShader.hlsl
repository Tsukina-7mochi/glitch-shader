#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "OpenLitCore.hlsl"
#include "Util.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D BG_TEXTURE_NAME;
fixed4 _Color;
float _ShadowThreshold;
float _AlphaCorrection;
uint _ReceiveShadow;
fixed4 _ShadowColor;
float _ShadowBoundaryWidth;
float _ScanLinePeriod;
fixed _ScanLineBrightness;
fixed _ChromaticAberrationIntensity;
float _ChromaticAberrationBaseZScalar;
fixed _GlitchSharpness;
fixed _GlitchDisplacementThreshold;
float _GlitchMaxY;
float _GlitchMinY;
float _GlitchDisplacement1;
float _GlitchPeriod1;
float _GlitchDisplacement2;
float _GlitchPeriod2;

// [OpenLit] Properties for lighting
float _AsUnlit;
float _VertexLightStrength;
float _LightMinLimit;
float _LightMaxLimit;
float _BeforeExposureLimit;
float _MonochromeLighting;
// float _AlphaBoostFA;
float4 _LightDirectionOverride;

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
    float4 grabPos : TEXCOORD3;
    // [OpenLit] Add light datas
    #if defined(_PACK_LIGHTDATAS)
        nointerpolation uint3 lightDatas : TEXCOORD4;
        UNITY_FOG_COORDS(5)
        UNITY_LIGHTING_COORDS(6, 7)
        #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
            float3 vertexLight  : TEXCOORD8;
        #endif
    #else
        nointerpolation float3 lightDirection : TEXCOORD4;
        nointerpolation float3 directLight : TEXCOORD5;
        nointerpolation float3 indirectLight : TEXCOORD6;
        UNITY_FOG_COORDS(7)
        UNITY_LIGHTING_COORDS(8, 9)
        #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
            float3 vertexLight  : TEXCOORD10;
        #endif
    #endif
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f Vertex(appdata v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f,o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    // apply Glitch
    float3 viewDir = ObjSpaceViewDir(v.vertex);
    float2 projectedViewDir = viewDir.xz;
    if(length(projectedViewDir) > _GlitchDisplacementThreshold) {
        float GlitchY1 = (1 - frac(_Time.y / _GlitchPeriod1)) * (_GlitchMaxY - _GlitchMinY) + _GlitchMinY;
        float GlitchY2 = (1 - frac(_Time.y / _GlitchPeriod2)) * (_GlitchMaxY - _GlitchMinY) + _GlitchMinY;

        float2 normPrjViewDir = normalize(projectedViewDir);
        float2 displacement1 = float2(-normPrjViewDir.y, normPrjViewDir.x) * _GlitchDisplacement1;
        float2 displacement2 = float2(-normPrjViewDir.y, normPrjViewDir.x) * _GlitchDisplacement2;
        v.vertex.xz += (1 - saturate(abs(v.vertex.y - GlitchY1) * _GlitchSharpness)) * displacement1;
        v.vertex.xz += (1 - saturate(abs(v.vertex.y - GlitchY2) * _GlitchSharpness)) * displacement2;
    }

    // scaling for chromatic aberration
    float4 scalar = float4(
        1 + _ChromaticAberrationIntensity * CHROMATIC_ABERRATION_SCALER,
        1 + _ChromaticAberrationIntensity * CHROMATIC_ABERRATION_SCALER,
        CHROMATIC_ABERRATION_Z_SCALER,
        1
    );

    o.positionWS = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
    o.pos = UnityWorldToClipPos(o.positionWS) * scalar;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normalWS = UnityObjectToWorldNormal(v.normalOS);
    o.grabPos = ComputeGrabScreenPos(o.pos);
    UNITY_TRANSFER_FOG(o,o.pos);
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

half4 Fragment(v2f i) : SV_Target
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

    col.rgb = maxElement(col.rgb);
    col.rgb *= (sin(i.pos.y / _ScanLinePeriod) < 0) ? _ScanLineBrightness : 1;

    half4 bgcol = tex2Dproj(BG_TEXTURE_NAME, i.grabPos);
    col.rgb = lerp(bgcol.rgb, col.rgb, saturate(pow(col.a, 1 - _AlphaCorrection * col.r)));
    col.a = 1;

    return col;
}