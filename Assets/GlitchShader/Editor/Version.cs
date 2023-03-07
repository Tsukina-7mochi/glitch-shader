using System;
using System.Text.RegularExpressions;
using UnityEngine;

namespace GlitchShader
{
    public class Version: IComparable
    {
        public readonly int Major;
        public readonly int Minor;
        public readonly int Patch;
        public readonly string Label;

        private static readonly Regex VersionStringRegex = new Regex("(\\d+)\\.(\\d+)\\.(\\d+)([0-9A-Za-z-.]+)?");

        public Version(int major, int minor, int patch, string label = "")
        {
            this.Major = major;
            this.Minor = minor;
            this.Patch = patch;
            this.Label = label;
        }
        
        public static Version Parse(string versionString)
        {
            var match = VersionStringRegex.Match(versionString);

            if (!match.Success)
            {
                throw new ArgumentException(versionString + " is not a valid version string.");
            }

            var major = int.Parse(match.Groups[1].Value);
            var minor = int.Parse(match.Groups[2].Value);
            var patch = int.Parse(match.Groups[3].Value);
            var label = match.Groups.Count < 4 ? "" : match.Groups[4].Value;

            return new Version(major, minor, patch, label);
        }

        public new string ToString()
        {
            return $"{this.Major}.{this.Minor}.{Patch}{Label}";
        }

        public int CompareTo(object obj)
        {
            if (!(obj is Version other)) return 1;

            if (this.Major > other.Major) return 1;
            if (this.Major < other.Major) return -1;
            if (this.Minor > other.Minor) return 1;
            if (this.Minor < other.Minor) return -1;
            if (this.Patch > other.Patch) return 1;
            if (this.Patch < other.Patch) return -1;
            if (this.Label == "" && other.Label == "") return 0;
            if (this.Label == "" && other.Label != "") return 1;
            if (this.Label != "" && other.Label == "") return -1;

            var thisLabel = this.Label.Split('.');
            var otherLabel = other.Label.Split('.');
            var length = Math.Min(thisLabel.Length, otherLabel.Length);
            for (var i = 0; i < length; i++)
            {
                var compared = string.Compare(thisLabel[i], otherLabel[i], StringComparison.Ordinal);
                if (compared != 0) return compared;
            }
            
            return thisLabel.Length - otherLabel.Length;
        }
    }
}