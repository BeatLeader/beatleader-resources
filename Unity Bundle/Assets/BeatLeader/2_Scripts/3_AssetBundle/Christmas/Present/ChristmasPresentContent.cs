using UnityEngine;
using UnityEngine.Serialization;

namespace BeatLeader {
    public class ChristmasPresentContent : MonoBehaviour {
        public Vector3 targetPosition;
        public float forceMultiplier = 20f; 
        public float damping = 0.95f;     

        [SerializeField]
        private Rigidbody _rigidBody;

        private void FixedUpdate() {
            var toTarget = targetPosition - _rigidBody.position;
            var force = toTarget * forceMultiplier;

            _rigidBody.AddForce(force);
            _rigidBody.velocity *= damping;
        }
    }
}