using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

namespace BeatLeader {
    [RequireComponent(typeof(AudioSource))]
    public class GlassEffectController : MonoBehaviour {
        [SerializeField] private AudioClip[] _breakClips;
        [SerializeField] private ParticleSystem[] _particleSystems;

        private AudioSource _audioSource;

        public void Play(Vector3 pos) {
            transform.position = pos;
            var clip = GetRandomClip();
            _audioSource.clip = clip;
            _audioSource.Play();
            foreach (var system in _particleSystems) {
                system.Emit(20);
            }
        }

        private void Awake() {
            _audioSource = GetComponent<AudioSource>();
            StartCoroutine(Test());
        }

        private IEnumerator Test() {
            while (true) {
                yield return new WaitForSeconds(1.5f);
                Play(Vector3.zero);
            }
        }

        private AudioClip GetRandomClip() {
            var count = _breakClips.Length;
            var rnd = Random.Range(0, count);
            return _breakClips[rnd];
        }
    }
}