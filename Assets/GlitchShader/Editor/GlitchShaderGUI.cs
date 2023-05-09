using System;
using GlitchShader;
using UnityEngine;
using UnityEditor;

namespace GlitchShader
{
    public class GlitchShaderGUI : ShaderGUI
    {
        private const string MainTexPropName = "_MainTex";
        private const string ColorPropName = "_Color";
        private const string ShadowThresholdPropName = "_ShadowThreshold";
        private const string ReceiveShadowPropName = "_ReceiveShadow";
        private const string ShadowColorPropName = "_ShadowColor";
        private const string ShadowBoundaryWidthPropName = "_ShadowBoundaryWidth";
        private const string ScanLinePeriodPropName = "_ScanLinePeriod";
        private const string ScanLineBrightnessPropName = "_ScanLineBrightness";
        private const string AlphaCorrectionPropName = "_AlphaCorrection";
        private const string ChrAbrIntensityPropName = "_ChromaticAberrationIntensity";
        private const string GlitchSharpnessPropName = "_GlitchSharpness";
        private const string GlitchDisplacementThresholdPropName = "_GlitchDisplacementThreshold";
        private const string GlitchMaxYPropName = "_GlitchMaxY";
        private const string GlitchMinYPropName = "_GlitchMinY";
        private const string GlitchDisplacement1PropName = "_GlitchDisplacement1";
        private const string GlitchPeriod1PropName = "_GlitchPeriod1";
        private const string GlitchDisplacement2PropName = "_GlitchDisplacement2";
        private const string GlitchPeriod2PropName = "_GlitchPeriod2";
        private const string AsUnlitPopName = "_AsUnlit";
        private const string VertexLightStrengthPropName = "_VertexLightStrength";
        private const string LightMinLimitPropName = "_LightMinLimit";
        private const string LightMaxLimitPropName = "_LightMaxLimit";
        private const string BeforeExposurePropName = "_BeforeExposureLimit";
        private const string MonochromeLightingPropName = "_MonochromeLighting";
        private const string LightDirectionOverridePropName = "_LightDirectionOverride";

        private static readonly string[] PopupItems =
        {
            GlitchShaderGUIText.EnText.LanguageDisplayName,
            GlitchShaderGUIText.JpText.LanguageDisplayName
        };

        private static readonly GlitchShaderGUIText[] Texts =
        {
            GlitchShaderGUIText.EnText,
            GlitchShaderGUIText.JpText
        };

        private static int _langPopupSelection = 1;
        private static GlitchShaderGUIText _text = Texts[_langPopupSelection];

        private static bool _shadowFoldoutOpen = true;
        private static bool _scanLineFoldoutOpen = true;
        private static bool _chrAbrFoldoutOpen = true;
        private static bool _glitchFoldoutOpen = true;
        private static bool _lightingFoldoutOpen = false;
        private static bool _advancedFoldoutOpen = false;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            var mainTexProp = FindProperty(MainTexPropName, properties);
            var colorProp = FindProperty(ColorPropName, properties);
            var shadowThresholdProp = FindProperty(ShadowThresholdPropName, properties);
            var receiveShadowProp = FindProperty(ReceiveShadowPropName, properties);
            var shadowColorProp = FindProperty(ShadowColorPropName, properties);
            var shadowBoundaryWidthProp = FindProperty(ShadowBoundaryWidthPropName, properties);
            var scanLinePeriodProp = FindProperty(ScanLinePeriodPropName, properties);
            var scanLineBrightnessProp = FindProperty(ScanLineBrightnessPropName, properties);
            var alphaCorrectionProp = FindProperty(AlphaCorrectionPropName, properties);
            var chrAbrIntensityProp = FindProperty(ChrAbrIntensityPropName, properties);
            var glitchSharpnessProp = FindProperty(GlitchSharpnessPropName, properties);
            var glitchDisplacementThresholdProp = FindProperty(GlitchDisplacementThresholdPropName, properties);
            var glitchMaxYProp = FindProperty(GlitchMaxYPropName, properties);
            var glitchMinYProp = FindProperty(GlitchMinYPropName, properties);
            var glitchDisplacement1Prop = FindProperty(GlitchDisplacement1PropName, properties);
            var glitchPeriod1Prop = FindProperty(GlitchPeriod1PropName, properties);
            var glitchDisplacement2Prop = FindProperty(GlitchDisplacement2PropName, properties);
            var glitchPeriod2Prop = FindProperty(GlitchPeriod2PropName, properties);
            var asUnlitProp = FindProperty(AsUnlitPopName, properties);
            var vertexLightStrengthProp = FindProperty(VertexLightStrengthPropName, properties);
            var lightMinLimitProp = FindProperty(LightMinLimitPropName, properties);
            var lightMaxLimitProp = FindProperty(LightMaxLimitPropName, properties);
            var beforeExposureLimitProp = FindProperty(BeforeExposurePropName, properties);
            var monochromeLightingProp = FindProperty(MonochromeLightingPropName, properties);
            var lightDirectionOverrideProp = FindProperty(LightDirectionOverridePropName, properties);

            // language settings
            var langPopupSelection = EditorGUILayout.Popup(
                new GUIContent("Language"),
                _langPopupSelection,
                PopupItems
            );
            if (langPopupSelection != _langPopupSelection)
            {
                _langPopupSelection = langPopupSelection;
                _text = Texts[_langPopupSelection];
            }

            EditorGUILayout.Space();

            // general settings
            materialEditor.TexturePropertySingleLine(
                _text.GetText(GlitchShaderGUIText.IdGeneralColor),
                mainTexProp,
                colorProp
            );

            materialEditor.RenderQueueField();

            EditorGUILayout.Space();

            // shadow settings
            _shadowFoldoutOpen = EditorGUILayout.Foldout(
                _shadowFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdShadow)
            );
            if (_shadowFoldoutOpen)
            {
                EditorGUI.indentLevel += 1;

                MyMaterialEditorGUILayout.FloatToggleProperty(
                    _text.GetText(GlitchShaderGUIText.IdShadowReceiveShadow),
                    receiveShadowProp
                );

                MyMaterialEditorGUILayout.ColorProperty(
                    _text.GetText(GlitchShaderGUIText.IdShadowColor),
                    shadowColorProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdShadowBoundaryWidth),
                    shadowBoundaryWidthProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdShadowThreshold),
                    shadowThresholdProp
                );

                EditorGUI.indentLevel -= 1;
            }

            // scan line settings
            _scanLineFoldoutOpen = EditorGUILayout.Foldout(
                _scanLineFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdScanline)
            );
            if (_scanLineFoldoutOpen)
            {
                EditorGUI.indentLevel += 1;

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdScanlineThickness),
                    scanLinePeriodProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdScanlineBrightness),
                    scanLineBrightnessProp
                );

                EditorGUI.indentLevel -= 1;
            }

            // chromatic aberration settings
            _chrAbrFoldoutOpen = EditorGUILayout.Foldout(
                _chrAbrFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdChrAbr)
            );
            if (_chrAbrFoldoutOpen)
            {
                EditorGUI.indentLevel += 1;

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdChrAbrIntensity),
                    chrAbrIntensityProp
                );

                EditorGUI.indentLevel -= 1;
            }

            // glitch settings
            _glitchFoldoutOpen = EditorGUILayout.Foldout(
                _glitchFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdGlitch)
            );
            if (_glitchFoldoutOpen)
            {
                EditorGUI.indentLevel += 1;

                var yRange = EditorGUILayout.Vector2Field(
                    _text.GetText(GlitchShaderGUIText.IdGlitchYRange),
                    new Vector2(glitchMinYProp.floatValue, glitchMaxYProp.floatValue)
                );
                glitchMinYProp.floatValue = yRange.x;
                glitchMaxYProp.floatValue = yRange.y;

                MyMaterialEditorGUILayout.FloatRangedProperty(
                    _text.GetText(GlitchShaderGUIText.IdGlitchSharpness),
                    glitchSharpnessProp,
                    0,
                    Single.PositiveInfinity
                );

                EditorGUILayout.LabelField(_text.GetText(GlitchShaderGUIText.IdGlitch1));
                EditorGUI.indentLevel += 1;
                MyMaterialEditorGUILayout.FloatProperty(
                    _text.GetText(GlitchShaderGUIText.IdGlitchIntensity),
                    glitchDisplacement1Prop
                );
                MyMaterialEditorGUILayout.FloatRangedProperty(
                    _text.GetText(GlitchShaderGUIText.IdGlitchPeriod),
                    glitchPeriod1Prop,
                    0,
                    Single.PositiveInfinity
                );
                EditorGUI.indentLevel -= 1;

                EditorGUILayout.LabelField(_text.GetText(GlitchShaderGUIText.IdGlitch2));
                EditorGUI.indentLevel += 1;
                MyMaterialEditorGUILayout.FloatProperty(
                    new GUIContent(_text.GetText(GlitchShaderGUIText.IdGlitchIntensity)),
                    glitchDisplacement2Prop
                );
                MyMaterialEditorGUILayout.FloatRangedProperty(
                    new GUIContent(_text.GetText(GlitchShaderGUIText.IdGlitchPeriod)),
                    glitchPeriod2Prop,
                    0,
                    Single.PositiveInfinity
                );
                EditorGUI.indentLevel -= 1;

                EditorGUI.indentLevel -= 1;
            }

            _lightingFoldoutOpen = EditorGUILayout.Foldout(
                _lightingFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdLighting)
            );
            if (_lightingFoldoutOpen)
            {
                EditorGUI.indentLevel += 1;

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingAsUnlit),
                    asUnlitProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingVertexLightStrength),
                    vertexLightStrengthProp
                );

                // MinMaxSlider does not have input box
                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingLightMinLimit),
                    lightMinLimitProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingLightMaxLimit),
                    lightMaxLimitProp
                );

                MyMaterialEditorGUILayout.FloatProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingBeforeExposure),
                    beforeExposureLimitProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingMonochromeLighting),
                    monochromeLightingProp
                );

                MyMaterialEditorGUILayout.VectorProperty(
                    _text.GetText(GlitchShaderGUIText.IdLightingLightDirectionOverride),
                    lightDirectionOverrideProp
                );

                EditorGUI.indentLevel -= 1;
            }

            _advancedFoldoutOpen = EditorGUILayout.Foldout(
                _advancedFoldoutOpen,
                _text.GetText(GlitchShaderGUIText.IdAdvanced)
            );
            if (_advancedFoldoutOpen)
            {
                MyMaterialEditorGUILayout.FloatProperty(
                    _text.GetText(GlitchShaderGUIText.IdAdvancedAlphaCorrection),
                    alphaCorrectionProp
                );

                MyMaterialEditorGUILayout.RangeProperty(
                    _text.GetText(GlitchShaderGUIText.IdAdvancedGlitchDisplacementThreshold),
                    glitchDisplacementThresholdProp
                );
            }
        }
    }
}
