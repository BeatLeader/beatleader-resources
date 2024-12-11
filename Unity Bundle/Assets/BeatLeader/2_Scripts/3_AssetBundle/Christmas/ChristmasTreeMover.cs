using UnityEngine;
using UnityEngine.EventSystems;

namespace BeatLeader {
    public class ChristmasTreeMover : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler {
        [SerializeField] private Transform _container;
        [SerializeField] private Material _material;

        public void OnPointerDown(PointerEventData eventData) { }

        public void OnPointerUp(PointerEventData eventData) { }

        public void OnPointerEnter(PointerEventData eventData) { }

        public void OnPointerExit(PointerEventData eventData) { }
    }
}