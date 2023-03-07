Shader "GlitchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ShadowThreshold ("Shadow Threshold", Range(-1,1)) = -0.3
        [Toggle(_)] _ReceiveShadow ("Receive Shadow", Int) = 0
        [Toggle(_PACK_LIGHTDATAS)] _PackLightDatas ("[Debug] Pack Light Datas", Int) = 0
        _ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 0.8, 1)
        _ShadowBoundaryWidth ("Shadow Boundary Width", Range(0, 1)) = 0.1
        _ScanLinePeriod ("Scan Line Thickness", Range(0.001, 5)) = 1
        _ScanLineBrightness ("Scan Line Brightness", Range(0, 1)) = 0.9
        _AlphaCorrection ("Alpha Correction", float) = 0.1
        _ChromaticAberrationIntensity ("Chromatic Aberration Intensity", Range(0, 1)) = 0.02
        _ChromaticAberrationBaseZScalar ("Chromatic Aberration Base Z Scalar", Range(0, 1)) = 0.99

        [Space]

        _GlitchSharpness ("Glitch Sharpness", float) = 100
        _GlitchDisplacementThreshold ("Glitch Displacement Threshold", Range(0, 1)) = 0.5
        _GlitchMaxY ("Glitch Maximum Y Coordinate", float) = 10
        _GlitchMinY ("Glitch Minimun Y Coordinate", float) = -10
        _GlitchDisplacement1 ("Glitch Displacement Amount", float) = 0.5
        _GlitchPeriod1 ("Glitch Period", float) = 31
        _GlitchDisplacement2 ("Glitch Displacement Amount", float) = -0.5
        _GlitchPeriod2 ("Glitch Period", float) = 23

        //// Properties for OpenLit ////
        [Space]
        _AsUnlit                ("As Unlit", Range(0,1)) = 0
        _VertexLightStrength    ("Vertex Light Strength", Range(0,1)) = 0
        _LightMinLimit          ("Light Min Limit", Range(0,1)) = 0.05
        _LightMaxLimit          ("Light Max Limit", Range(0,10)) = 1
        _BeforeExposureLimit    ("Before Exposure Limit", Float) = 10000
        _MonochromeLighting     ("Monochrome lighting", Range(0,1)) = 0
        // _AlphaBoostFA           ("Boost Transparency in ForwardAdd", Range(1,100)) = 10
        _LightDirectionOverride ("Light Direction Override", Vector) = (0.001,0.002,0.001,0)
    }

    CustomEditor "GlitchShader.GlitchShaderGUI"

    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "VRCFallback"="ToonTransparent"
        }

        GrabPass { "_BackgroundTextureR" }

        Pass
        {
            ColorMask R
            HLSLPROGRAM

            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _PACK_LIGHTDATAS
            #if defined(SHADER_API_GLES)
                #undef _PACK_LIGHTDATAS
            #endif

            #define BG_TEXTURE_NAME _BackgroundTextureR
            #define CHROMATIC_ABERRATION_SCALER 0
            #define CHROMATIC_ABERRATION_Z_SCALER _ChromaticAberrationBaseZScalar * _ChromaticAberrationBaseZScalar
            #include "GlitchShader.hlsl"

            ENDHLSL
        }

        GrabPass { "_BackgroundTextureG" }

        Pass
        {
            ColorMask G
            HLSLPROGRAM

            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _PACK_LIGHTDATAS
            #if defined(SHADER_API_GLES)
                #undef _PACK_LIGHTDATAS
            #endif

            #define BG_TEXTURE_NAME _BackgroundTextureG
            #define CHROMATIC_ABERRATION_SCALER 0.5
            #define CHROMATIC_ABERRATION_Z_SCALER _ChromaticAberrationBaseZScalar
            #include "GlitchShader.hlsl"

            ENDHLSL
        }

        GrabPass { "_BackgroundTextureB" }

        Pass
        {
            ColorMask B
            HLSLPROGRAM

            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _PACK_LIGHTDATAS
            #if defined(SHADER_API_GLES)
                #undef _PACK_LIGHTDATAS
            #endif

            #define BG_TEXTURE_NAME _BackgroundTextureB
            #define CHROMATIC_ABERRATION_SCALER 1
            #define CHROMATIC_ABERRATION_Z_SCALER 1
            #include "GlitchShader.hlsl"

            ENDHLSL
        }
    }
}
