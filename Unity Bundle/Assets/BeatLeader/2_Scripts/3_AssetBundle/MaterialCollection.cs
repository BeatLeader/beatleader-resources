using UnityEngine;

namespace BeatLeader {
    [CreateAssetMenu(fileName = "MaterialCollection", menuName = "MaterialCollection")]
    public class MaterialCollection : ScriptableObject {
        public Material blurMaterial;
        public Material plotterMaterial;
        public Material applicatorMaterial;
        public Material uiAdditiveGlowMaterial;
        public Material uiNoDepthMaterial;
        public Material uiRoundTexture2Material;
        public Material uiRoundTexture10Material;
    }
}