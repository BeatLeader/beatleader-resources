using UnityEngine;

namespace BeatLeader {
    public class BattleRoyaleSaberVRController : BattleRoyaleVRController {
        [SerializeField]
        private MeshRenderer bladeRenderer;

        [SerializeField]
        private MeshRenderer handleRenderer;

        protected override void ApplyBlock(MaterialPropertyBlock block) {
            bladeRenderer.SetPropertyBlock(block);
            handleRenderer.SetPropertyBlock(block);
        }
    }
}