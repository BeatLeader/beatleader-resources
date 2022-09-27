using UnityEngine;

namespace BeatLeader {
    [RequireComponent(typeof(MeshRenderer))]
    public class GifLoaderTest : MonoBehaviour {
        #region TestImages

        private static readonly string[] TestImages = {
            "https://cdn.beatleader.xyz/assets/76561198110147969.png?"
        };

        private static string GetRandomImage() {
            return TestImages[(int) (Random.value * TestImages.Length)];
        }

        #endregion

        private static readonly int AvatarTexture = Shader.PropertyToID("_AvatarTexture");
        private static readonly int FadeValuePropertyId = Shader.PropertyToID("_FadeValue");

        private Material _materialInstance;
        private RenderTexture _target;

        private void Start() {
            _target = new RenderTexture(512, 512, 0);
            _target.Create();

            var meshRenderer = GetComponent<MeshRenderer>();
            _materialInstance = Instantiate(meshRenderer.material);
            _materialInstance.SetTexture(AvatarTexture, _target);
            _materialInstance.SetFloat(FadeValuePropertyId, 0);
            meshRenderer.material = _materialInstance;

            StartCoroutine(AvatarStorage.GetPlayerAvatarCoroutine(GetRandomImage(), false, OnAvatarReady, OnAvatarFailed));
        }

        private void OnAvatarReady(AvatarImage avatarImage) {
            Debug.Log($"OnAvatarReady");
            _materialInstance.SetFloat(FadeValuePropertyId, 1);
            StartCoroutine(avatarImage.PlaybackCoroutine(_target));
        }

        private void OnAvatarFailed(string reason) {
            Debug.Log($"avatar failed: {reason}");
            _materialInstance.SetFloat(FadeValuePropertyId, 1);
        }

        private void OnDestroy() {
            _target.Release();
        }
    }
}