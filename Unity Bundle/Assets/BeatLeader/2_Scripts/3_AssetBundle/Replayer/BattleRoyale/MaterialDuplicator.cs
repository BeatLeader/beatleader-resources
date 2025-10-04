using UnityEngine;

namespace BeatLeader {
    public class MaterialDuplicator : MonoBehaviour {
        [SerializeField] 
        private MeshRenderer meshRenderer;

        private Material _material;
        
        private void Awake() {
            var sourceMaterial = meshRenderer.material;
            var clonedMaterial = Instantiate(sourceMaterial);
            _material = clonedMaterial;
            meshRenderer.material = clonedMaterial;
        }

        private void OnDestroy() {
            Destroy(_material);
        }
    }
}