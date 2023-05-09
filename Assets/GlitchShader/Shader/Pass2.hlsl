#include "UnityCG.cginc"
#include "Util.hlsl"

#ifndef _BgGrabTextureName
#error "_BgGrabTextureName undefined"
#endif

#ifndef _PrevPassGrabTextureName
#error "_PrevPassGrabTextureName undefined"
#endif

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _Color;
float _AlphaCorrection;
fixed _ChromaticAberrationIntensity;
fixed _GlitchSharpness;
fixed _GlitchDisplacementThreshold;
float _GlitchMaxY;
float _GlitchMinY;
float _GlitchDisplacement1;
float _GlitchPeriod1;
float _GlitchDisplacement2;
float _GlitchPeriod2;
sampler2D _BgGrabTextureName;
sampler2D _PrevPassGrabTextureName;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 grabPosR : TEXCOORD1;
    float4 grabPosG : TEXCOORD2;
    float4 grabPosB : TEXCOORD3;
};

v2f vert (appdata v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f,o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    // apply glitch
    float3 viewDir = ObjSpaceViewDir(v.vertex);
    float2 projectedViewDir = viewDir.xz;
    if(length(projectedViewDir) > _GlitchDisplacementThreshold) {
        float2 normPrjViewDir = normalize(projectedViewDir);
        float2 displacement1 = computeGlitch(
            v.vertex.y,
            _GlitchPeriod1,
            _GlitchMinY,
            _GlitchMaxY,
            normPrjViewDir,
            _GlitchSharpness
        ) * _GlitchDisplacement1;
        float2 displacement2 = computeGlitch(
            v.vertex.y,
            _GlitchPeriod2,
            _GlitchMinY,
            _GlitchMaxY,
            normPrjViewDir,
            _GlitchSharpness
        ) * _GlitchDisplacement2;
        v.vertex.xz += displacement1 + displacement2;
    }

    // compute grabPos for chromatic aberration
    float caMultiplier = 1 - _ChromaticAberrationIntensity;

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    float4 clipPos = o.vertex;
    o.grabPosR = ComputeGrabScreenPos(clipPos);
    clipPos.xy *= caMultiplier;
    o.grabPosG = ComputeGrabScreenPos(clipPos);
    clipPos.xy *= caMultiplier;
    o.grabPosB = ComputeGrabScreenPos(clipPos);
    return o;
}

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
