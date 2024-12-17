using System.Collections;
using UnityEngine;
using Random = System.Random;

namespace BeatLeader {
    public class ChristmasPresent : MonoBehaviour {
        [SerializeField] private Rigidbody _body;
        [SerializeField] private Rigidbody _lid;
        [SerializeField] private ChristmasPresentContent _content;
        [SerializeField] private Rigidbody _contentRigidBody;
        [SerializeField] private ParticleSystem _particleSystem;

        private static float GetRandomOffset() {
            var random = new Random();
            return random.Next(-10, 10) * 0.1f;
        }

        public IEnumerator Present() {
            var offset = new Vector3(
                GetRandomOffset(),
                GetRandomOffset(),
                GetRandomOffset()
            );
            _lid.AddExplosionForce(1600f, transform.position + offset, 10f, 10f);
            _body.AddExplosionForce(300f, transform.position, 10f, 10f);
            _contentRigidBody.AddExplosionForce(1300f, transform.position + offset, 10f, 10f);
            _contentRigidBody.useGravity = true;

            _particleSystem.Play(true);

            yield return new WaitForSeconds(1.5f);
            _content.targetPosition = new Vector3(3f, 6f, 0f);
            _content.enabled = true;
        }

        private void Start() {
            StartCoroutine(Coroutine());
        }

        private IEnumerator Coroutine() {
            _particleSystem.Stop();
            yield return new WaitForSeconds(1.5f);
            yield return Present();
        }
    }
}