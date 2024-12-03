using UnityEngine;

public class ChristmasTreeDecoration : MonoBehaviour {
    public ChristmasTree christmasTree;

    private void Update() {
        transform.position = christmasTree.Align(transform.position);
    }
}