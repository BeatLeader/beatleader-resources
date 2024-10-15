using UnityEngine;

namespace BeatLeader {
    public class BattleRoyaleHeadVRController : BattleRoyaleVRController {
        [SerializeField]
        private MeshRenderer headRenderer;

        protected override void ApplyBlock(MaterialPropertyBlock block) {
            headRenderer.SetPropertyBlock(block);
        }
    }
}