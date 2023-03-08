using System;
using System.Collections;
using UnityEngine;
using UnityEditor;
using UnityEngine.Networking;
using UnityEngine.PlayerLoop;

namespace GlitchShader
{
    [Serializable]
    public class ReleaseResponse
    {
        public string name;
    }

    [InitializeOnLoad]
    public class UpdateChecker: MonoBehaviour
    {
        public static readonly Version CurrentVersion = new Version(1, 0, 0);
        public static string GitHubURL = "https://api.github.com/repos/Tsukina-7mochi/glitch-shader/releases/latest";

        private static IEnumerator _checkUpdate(bool showLatest)
        {
            var req = UnityWebRequest.Get(GitHubURL);
            yield return req.SendWebRequest();

            if (req.isNetworkError || req.isHttpError || req.responseCode != 200)
            {
                Debug.LogError("[Glitch Shader] Failed to fetch update.");
            }
            else
            {
                var text = req.downloadHandler.text;
                ReleaseResponse response = JsonUtility.FromJson<ReleaseResponse>(text);

                var version = Version.Parse(response.name);
                if (CurrentVersion.CompareTo(version) < 0)
                {
                    Debug.Log($"[Glitch Shader] Update {version.ToString()} is available.");
                } else if (showLatest)
                {
                    Debug.Log($"[Glitch Shader] Glitch Shader is up to date: {CurrentVersion.ToString()}");
                }
            }
        }

        private static void StartCheckUpdate(bool showLatest)
        {
            Util.CoroutineRunner.Run(_checkUpdate(showLatest));
        }

        [MenuItem("Window/Glitch Shader/Check for update")]
        static void CheckUpdate()
        {
            StartCheckUpdate(true);
        }
        static UpdateChecker()
        {
            StartCheckUpdate(false);
        }
    }
}