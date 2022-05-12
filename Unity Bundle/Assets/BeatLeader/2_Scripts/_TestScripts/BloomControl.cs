using UnityEngine;

namespace BeatLeader {
    [ExecuteInEditMode]
    public class BloomControl : MonoBehaviour {
        [SerializeField] private bool fakeBloomEnabled = true;

        private static readonly int FakeBloomAmountPropertyID = Shader.PropertyToID("_FakeBloomAmount");

        private void OnValidate() {
            Shader.SetGlobalFloat(FakeBloomAmountPropertyID, fakeBloomEnabled ? 1.0f : 0.0f);
        }
    }
}