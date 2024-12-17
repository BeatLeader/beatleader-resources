using UnityEngine;

namespace BeatLeader {
    public class SnowController : MonoBehaviour {
        [SerializeField]
        private ParticleSystem _particleSystem;

        private void Start() {
            Play(true);
        }

        public void Play(bool immediate) {
            var emission = _particleSystem.emission;
            emission.enabled = true;
            if (immediate) {
                var duration = _particleSystem.main.startLifetimeMultiplier;
                _particleSystem.Simulate(duration, true, true, true);
            }
            _particleSystem.Play();
        }

        public void Stop(bool immediate) {
            var emission = _particleSystem.emission;
            emission.enabled = false;
        }
    }
}