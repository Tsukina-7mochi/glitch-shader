using UnityEngine;
using UnityEditor;

namespace GlitchShader
{
    public static class MyMaterialEditorGUILayout
    {
        public static Color ColorProperty(
            GUIContent label,
            MaterialProperty property,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.ColorField(
                label,
                property.colorValue,
                options
            );
            property.colorValue = value;
            return value;
        }

        public static float FloatProperty(
            GUIContent label,
            MaterialProperty property,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.FloatField(
                label,
                property.floatValue,
                options
            );
            property.floatValue = value;
            return value;
        }
        
        public static float FloatRangedProperty(
            GUIContent label,
            MaterialProperty property,
            float min,
            float max,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.FloatField(
                label,
                property.floatValue,
                options
            );
            value = Mathf.Min(Mathf.Max(value, min), max);
            property.floatValue = value;
            return value;
        }

        public static float FloatToggleProperty(
            GUIContent label,
            MaterialProperty property,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.Toggle(
                label,
                property.floatValue != 0f,
                options
            ) ? 1f : 0f;
            property.floatValue = value;
            return value;
        }

        public static float RangeProperty(
            GUIContent label,
            MaterialProperty property,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.Slider(
                label,
                property.floatValue,
                property.rangeLimits.x,
                property.rangeLimits.y,
                options
            );
            property.floatValue = value;
            return value;
        }

        public static Vector4 VectorProperty(
            GUIContent label,
            MaterialProperty property,
            params GUILayoutOption[] options
        )
        {
            var value = EditorGUILayout.Vector4Field(
                label,
                property.vectorValue,
                options
            );
            property.vectorValue = value;
            return value;
        }
    }
}