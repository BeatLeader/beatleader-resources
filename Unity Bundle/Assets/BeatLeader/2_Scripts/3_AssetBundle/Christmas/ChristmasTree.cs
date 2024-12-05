using System.Linq;
using UnityEngine;

namespace BeatLeader {
    public class ChristmasTree : MonoBehaviour {
        [SerializeField]
        public ChristmasTreeLevel[] _levels;

        [SerializeField]
        private Transform _animationContainer;

        public bool gizmos;
        public float animationSpeed = 10f;

        private float _targetScale;
        private bool _set = true;

        public void Present() {
            _targetScale = 1f;
            _set = false;
        }

        public void Dismiss() {
            _targetScale = 0f;
            _set = false;
        }

        private void Update() {
            if (_set) return;

            var t = Time.deltaTime * animationSpeed;
            var targetScale = _targetScale * Vector3.one;
            var scale = Vector3.Lerp(_animationContainer.localScale, targetScale, t);

            if (Mathf.Abs(scale.x - targetScale.x) <= 0.001f) {
                scale = targetScale;
                _set = true;
            }

            _animationContainer.localScale = scale;
        }

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
    }
}