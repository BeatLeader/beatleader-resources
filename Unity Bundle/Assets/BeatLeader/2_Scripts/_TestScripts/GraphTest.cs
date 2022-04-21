using UnityEngine;

namespace BeatLeader {
    public class GraphTest : MonoBehaviour {
        [SerializeField] private Transform targetTransform;
        [SerializeField] private GameObject reeGraphPrefab;
        [SerializeField] private float canvasRadius = 100.0f;
        [SerializeField] private float[] points;

        private AccuracyGraph _accuracyGraph;

        private void Start() {
            var go = Instantiate(reeGraphPrefab, targetTransform, false);
            _accuracyGraph = go.GetComponent<AccuracyGraph>();
            go.transform.SetSiblingIndex(1);
        }

        private void Update() {
            _accuracyGraph.SetPoints(points, canvasRadius);
        }

        private void OnDrawGizmos() {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireCube(
                transform.TransformPoint(new Vector3(0.5f, 0.5f, 0.0f)),
                transform.TransformVector(new Vector3(1, 1, 0))
            );
            for (var i = 1; i < points.Length; i++) {
                Vector3 GetPosition(int index) {
                    var y = points[index];
                    var x = (float) index / (points.Length - 1);
                    return transform.TransformPoint(new Vector3(x, y, 0));
                }

                Gizmos.DrawSphere(GetPosition(i), 0.6f);
                Gizmos.DrawLine(GetPosition(i - 1), GetPosition(i));
            }
        }
    }
}