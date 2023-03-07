using System.Collections.Generic;
using UnityEngine;

namespace GlitchShader
{
    public class GlitchShaderGUIText
    {
        public const int IdDefaultBtn = 0;
        
        public const int IdGeneral = 100;
        public const int IdGeneralColor = IdGeneral + 1;
        
        public const int IdShadow = 200;
        public const int IdShadowReceiveShadow = IdShadow + 1;
        public const int IdShadowColor = IdShadow + 2;
        public const int IdShadowBoundaryWidth = IdShadow + 3;
        public const int IdShadowThreshold = IdShadow + 4;
        
        public const int IdScanline = 300;
        public const int IdScanlineThickness = IdScanline + 1;
        public const int IdScanlineBrightness = IdScanline + 2;
        
        public const int IdChrAbr = 400;
        public const int IdChrAbrIntensity = IdChrAbr + 1;

        public const int IdGlitch = 500;
        public const int IdGlitchYRange = IdGlitch + 1;
        public const int IdGlitchSharpness = IdGlitch + 2;
        public const int IdGlitch1 = IdGlitch + 3;
        public const int IdGlitch2 = IdGlitch + 4;
        public const int IdGlitchIntensity = IdGlitch + 5;
        public const int IdGlitchPeriod = IdGlitch + 6;
        
        public const int IdLighting = 600;
        public const int IdLightingAsUnlit = IdLighting + 1;
        public const int IdLightingVertexLightStrength = IdLighting + 2;
        public const int IdLightingLightMinLimit = IdLighting + 3;
        public const int IdLightingLightMaxLimit = IdLighting + 4;
        public const int IdLightingBeforeExposure = IdLighting + 5;
        public const int IdLightingMonochromeLighting = IdLighting + 6;
        public const int IdLightingLightDirectionOverride = IdLighting + 7;

        public const int IdAdvanced = 700;
        public const int IdAdvancedAlphaCorrection = IdAdvanced + 1;
        public const int IdAdvancedChrAbrBaseZScalar = IdAdvanced + 2;
        public const int IdAdvancedGlitchDisplacementThreshold = IdAdvanced + 3;

        public static readonly GlitchShaderGUIText EnText = new GlitchShaderGUIText(
            "en",
            "English",
            (IdDefaultBtn, new GUIContent("Reset all configurations to default")),
            (IdGeneral, new GUIContent("General Settings")),
            (IdGeneralColor, new GUIContent("Color", "Main texture and base color")),
            (IdShadow, new GUIContent("Shadow Settings")),
            (IdShadowReceiveShadow, new GUIContent("Receive shadow", "Whether shadows are received from external light sources")),
            (IdShadowColor, new GUIContent("Color")),
            (IdShadowBoundaryWidth, new GUIContent("Boundary width")),
            (IdShadowThreshold, new GUIContent("Threshold", "Threshold for the range of shadows to be drawn")),
            (IdScanline, new GUIContent("Scanline Settings")),
            (IdScanlineThickness, new GUIContent("Thickness")),
            (IdScanlineBrightness, new GUIContent("Brightness")),
            (IdChrAbr, new GUIContent("Chromatic Aberration Settings")),
            (IdChrAbrIntensity, new GUIContent("Intensity")),
            (IdGlitch, new GUIContent("Glitch Settings")),
            (IdGlitchYRange, new GUIContent("Y range start/end", "The glitch effect appears periodically in the range of coordinates from the set y start value to the set y end value")),
            (IdGlitchSharpness, new GUIContent("Sharpness", "The larger the value, the sharper the glitch; effects may not appear at larger values")),
            (IdGlitch1, new GUIContent("Glitch 1")),
            (IdGlitch2, new GUIContent("Glitch 2")),
            (IdGlitchIntensity, new GUIContent("Intensity", "The size of glitch effect")),
            (IdGlitchPeriod, new GUIContent("Period")),
            (IdLighting, new GUIContent("Lighting Settings")),
            (IdLightingAsUnlit, new GUIContent("As unlit", "Degree of disregard for light source effects")),
            (IdLightingVertexLightStrength, new GUIContent("Vertex light strength")),
            (IdLightingLightMinLimit, new GUIContent("Light min limit")),
            (IdLightingLightMaxLimit, new GUIContent("Light max limit")),
            (IdLightingBeforeExposure, new GUIContent("Before exposure limit")),
            (IdLightingMonochromeLighting, new GUIContent("Monochrome lighting")),
            (IdLightingLightDirectionOverride, new GUIContent("Light direction override")),
            (IdAdvanced, new GUIContent("Advanced Settings")),
            (IdAdvancedAlphaCorrection, new GUIContent("Alpha correction", "Corrects transparency based on lightness; the greater the value, the greater the black transparency")),
            (IdAdvancedChrAbrBaseZScalar, new GUIContent("Chromatic aberration channel Z scalar", "Correction value of clip Z value for each channel of chromatic aberration")),
            (IdAdvancedGlitchDisplacementThreshold, new GUIContent("Glitch threshold", "Angle of view threshold to enable glitching"))
        );
        
        public static readonly GlitchShaderGUIText JpText = new GlitchShaderGUIText(
            "jp",
            "日本語",
            (IdDefaultBtn, new GUIContent("すべての設定をデフォルトに戻す")),
            (IdGeneral, new GUIContent("一般設定")),
            (IdGeneralColor, new GUIContent("色", "テクスチャとベースカラー")),
            (IdShadow, new GUIContent("影設定")),
            (IdShadowReceiveShadow, new GUIContent("影を受け取る", "外部の光源から影を受け取るかどうか")),
            (IdShadowColor, new GUIContent("色")),
            (IdShadowBoundaryWidth, new GUIContent("境界の幅")),
            (IdShadowThreshold, new GUIContent("しきい値", "影が描画される領域のしきい値")),
            (IdScanline, new GUIContent("走査線の設定")),
            (IdScanlineThickness, new GUIContent("太さ")),
            (IdScanlineBrightness, new GUIContent("明るさ")),
            (IdChrAbr, new GUIContent("色収差の設定")),
            (IdChrAbrIntensity, new GUIContent("強さ")),
            (IdGlitch, new GUIContent("グリッチの設定")),
            (IdGlitchYRange, new GUIContent("Yの範囲 開始/終了", "グリッチエフェクトは開始のy座標から終了のy座標の範囲に周期的に現れる")),
            (IdGlitchSharpness, new GUIContent("鋭さ", "大きいほどグリッチエフェクトが鋭くなるが、大きすぎる値を設定するとエフェクトが現れなくなる")),
            (IdGlitch1, new GUIContent("グリッチ 1")),
            (IdGlitch2, new GUIContent("グリッチ 2")),
            (IdGlitchIntensity, new GUIContent("強さ", "グリッチエフェクトの大きさ")),
            (IdGlitchPeriod, new GUIContent("周期")),
            (IdLighting, new GUIContent("ライティング設定")),
            (IdLightingAsUnlit, new GUIContent("Unlit化", "光源の影響を無視する度合い")),
            (IdLightingVertexLightStrength, new GUIContent("頂点ライトの強さ")),
            (IdLightingLightMinLimit, new GUIContent("明るさの下限")),
            (IdLightingLightMaxLimit, new GUIContent("明るさの上限")),
            (IdLightingBeforeExposure, new GUIContent("Before exposure limit")),
            (IdLightingMonochromeLighting, new GUIContent("光源のモノクロ化")),
            (IdLightingLightDirectionOverride, new GUIContent("光源の向きの上書き")),
            (IdAdvanced, new GUIContent("高度な設定")),
            (IdAdvancedAlphaCorrection, new GUIContent("透明度補正", "透明度を明度に基づいて補正する/値が大きいほど黒色の透明度が大きくなる")),
            (IdAdvancedChrAbrBaseZScalar, new GUIContent("色収差のZチャンネル拡大率", "色収差の各チャンネルのクリップz座標の補正値")),
            (IdAdvancedGlitchDisplacementThreshold, new GUIContent("グリッチのしきい値", "グリッチを有効化する視線の角度のしきい値"))
        );

        public readonly string Language;
        public readonly string LanguageDisplayName;

        protected readonly Dictionary<int, GUIContent> Texts;

        public GlitchShaderGUIText(string lang, string langDisplayName, params (int, GUIContent)[] texts)
        {
            this.Language = lang;
            this.LanguageDisplayName = langDisplayName;
            this.Texts = new Dictionary<int, GUIContent>();

            foreach (var item in texts)
            {
                this.Texts.Add(item.Item1, item.Item2);
            }
        }

        public GUIContent GetText(int id)
        {
            return this.Texts[id];
        }
    }
}