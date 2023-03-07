using System;
using System.Collections;
using UnityEngine;

namespace GlitchShader
{
    namespace Util
    {
        public class CoroutineRunner: MonoBehaviour
        {
            private static GameObject _gameObject = null;

            public void OnDisable()
            {
                if (_gameObject)
                {
                    Destroy(_gameObject);
                }
            }

            public static void Run(IEnumerator coroutine)
            {
                _gameObject = new GameObject("GlitchShaderUpdateCheckerCoroutineRunner");
                _gameObject.hideFlags = HideFlags.HideAndDontSave;
                var instance = _gameObject.AddComponent<CoroutineRunner>();
                
                instance.StartCoroutine(coroutine);
            }
        }
    }
}