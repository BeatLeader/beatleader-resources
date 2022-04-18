using UnityEngine;

namespace BeatLeader {
    //Assembly name and namespace MUST be the same as the plugin!!!!!!!!!!
    public class GifLoaderTest : MonoBehaviour {
        #region Serialized

        [SerializeField] private Material material;
        [SerializeField] private MeshRenderer meshRenderer;

        private static readonly int FadeValuePropertyId = Shader.PropertyToID("_FadeValue");

        #endregion

        #region TestImages

        private static readonly string[] TestImages = {
            "https://i.pinimg.com/originals/91/8c/ee/918ceed0f498a7d9a637e7ffe2b74080.gif",
            "https://c.tenor.com/hVRzRZnx-YsAAAAM/pepe-the-frog-sitting-chillin.gif",
            "https://i.gifer.com/origin/f5/f5baef4b6b6677020ab8d091ef78a3bc_w200.gif",
            "https://cdn.beatleader.xyz/assets/76561198059961776.png",
            "https://cdn.beatleader.xyz/assets/76561198962773013.png",
            "https://media2.giphy.com/media/BIuuwHRNKs15C/200.gif"
        };

        private static string GetRandomImage() {
            return TestImages[(int) (Random.value * TestImages.Length)];
        }

        #endregion

        private static readonly int AvatarTexture = Shader.PropertyToID("_AvatarTexture");

        private Material _materialInstance;
        private RenderTexture _target;

        private void Start() {
            _target = new RenderTexture(512, 512, 0);
            _target.Create();

            _materialInstance = Instantiate(material);
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