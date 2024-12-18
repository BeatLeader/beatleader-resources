using UnityEngine;

namespace BeatLeader {
    public class ChristmasPresent : MonoBehaviour {
        private static readonly int OpenId = Animator.StringToHash("Open");

        [SerializeField] private Animator _animator;
        [SerializeField] private Transform _toyContainer;

        //TODO: REMOVE BEFORE BUILD
        [SerializeField] private Transform _toy;

        // Call once user has pressed a trigger/button
        public void Open() {
            _animator.SetTrigger(OpenId);
        }

        // Call once user has pressed a trigger/button after opening
        public void Dismiss() {
            _animator.enabled = false;
        }

        public void Present(Transform toy) {
            toy.SetParent(_toyContainer, false);
            _animator.Update(0f);
            _animator.enabled = true;
        }
        
        //TODO: REMOVE BEFORE BUILD
        private void Start() {
            Present(_toy);
        }
    }
}