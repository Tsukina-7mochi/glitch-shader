#ifndef GLITCH_SHADER_PROPERTIES_INCLUDED
#define GLITCH_SHADER_PROPERTIES_INCLUDED

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _Color;
float _ShadowThreshold;
uint _ReceiveShadow;
fixed4 _ShadowColor;
float _ShadowBoundaryWidth;
float _ScanLinePeriod;
fixed _ScanLineBrightness;
float _AlphaCorrection;
fixed _ChromaticAberrationIntensity;

// Glitch
float _GlitchSharpness;
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
float _MonochromeLighting;
float4 _LightDirectionOverride;

#endif // GLITCH_SHADER_PROPERTIES_INCLUDED
