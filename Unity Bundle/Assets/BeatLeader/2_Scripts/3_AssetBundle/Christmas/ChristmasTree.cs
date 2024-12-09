using System.Linq;
using UnityEngine;

namespace BeatLeader {
    public class ChristmasTree : MonoBehaviour {
        [SerializeField] private ChristmasTreeLevel[] _levels;
        [SerializeField] private CapsuleCollider _collider;
        [SerializeField] private ChristmasTreeAnimator _animator;
        public bool gizmos;

        #region Editor

        public Vector3 Align(Vector3 pos) {
            var y = pos.y;

            var level = _levels.FirstOrDefault(level => y >= level.bottomHeight && y <= level.topHeight);
            if (level == null) {
                Debug.LogWarning("Position does not align with any tree level.");
                return pos;
            }

            var t = (y - level.bottomHeight) / (level.topHeight - level.bottomHeight);
            var radiusAtHeight = Mathf.Lerp(level.bottomRadius, level.topRadius, t);

            var xz = new Vector2(pos.x, pos.z);
            xz = radiusAtHeight * (xz == Vector2.zero ? Vector2.right : xz.normalized);

            return new Vector3(xz.x, pos.y, xz.y);
        }

        private void OnDrawGizmos() {
            if (!gizmos) return;
            foreach (var t in _levels) {
                t.Draw(transform.lossyScale.x);
            }
        }

        #endregion
    }
}