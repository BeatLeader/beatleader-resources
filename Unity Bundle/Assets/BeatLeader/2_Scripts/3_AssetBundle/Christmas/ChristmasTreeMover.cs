using UnityEngine;
using UnityEngine.EventSystems;

namespace BeatLeader {
    public class ChristmasTreeMover : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler {
        private static readonly int treePositionPropertyId = Shader.PropertyToID("_TreePosition");

        [SerializeField] private Transform _container;
        [SerializeField] private Material _material;

        private void Update() {
            var shaderPos = _container.position;
            shaderPos.y += 1.5f;
            Shader.SetGlobalVector(treePositionPropertyId, shaderPos);
        }

        public void OnPointerDown(PointerEventData eventData) { }

        public void OnPointerUp(PointerEventData eventData) { }

        public void OnPointerEnter(PointerEventData eventData) { }

        public void OnPointerExit(PointerEventData eventData) { }
    }
}