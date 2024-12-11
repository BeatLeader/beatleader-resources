using System.Linq;
using UnityEngine;

namespace BeatLeader {
    public class ChristmasTree : MonoBehaviour {
        [SerializeField] private ChristmasTreeLevel[] _levels;
        [SerializeField] private ChristmasTreeAnimator _animator;
        [SerializeField] private ChristmasTreeMover _mover;
        [SerializeField] private Transform _mesh;
        [SerializeField] private float _radius;
        public bool gizmos;

        public bool HasAreaContact(Vector3 pos) {
            var mul = _mesh.localScale;
            pos = _mesh.InverseTransformPoint(pos);
            return Mathf.Abs(pos.x) <= _radius * mul.x && Mathf.Abs(pos.z) <= _radius * mul.z;
        }
        
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
            DrawCircle(transform.position, _radius, 21);
            foreach (var t in _levels) {
                t.Draw(transform.lossyScale.x);
            }
        }

        private static void DrawCircle(Vector3 center, float radius, int segments) {
            var angleStep = 360f / segments;
            var previousPoint = center + Vector3.right * radius;

            for (var i = 1; i <= segments; i++) {
                var angle = angleStep * i * Mathf.Deg2Rad;
                var newPoint = center + new Vector3(Mathf.Cos(angle) * radius, 0, Mathf.Sin(angle) * radius);

                // Draw the circle segment
                Gizmos.DrawLine(previousPoint, newPoint);

                previousPoint = newPoint;
            }
        }
        
        #endregion
    }
}