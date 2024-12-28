using System;
using System.Collections;
using System.IO;
using UnityEngine;

public class BundlesPacker : MonoBehaviour {
    public Transform smol;

    public Camera cam;
    public GameObject[] prefabs;

    private RenderTexture _renderTexture;

    private void Start() {
        _renderTexture = new RenderTexture(512, 512, 24, RenderTextureFormat.ARGBFloat) {
            antiAliasing = 8
        };
        _renderTexture.Create();

        cam.targetTexture = _renderTexture;
        StartCoroutine(RenderPreviews());

        Shader.EnableKeyword("PREVIEW_RENDERER");
    }

    private IEnumerator RenderPreviews() {
        var compiledBundlesDirectory = new DirectoryInfo(@"D:\Projects\Beat Saber\BeatLeader\Christmas\beatleader-mod-tree\Source\9_Resources\AssetBundles\");
        var targetDirectory = new DirectoryInfo(@"D:\Projects\Beat Saber\project-tree\bundles\");
        targetDirectory.Create();

        foreach (var fileInfo in targetDirectory.GetFiles()) {
            Debug.Log($"file: {fileInfo.FullName}");
            fileInfo.Delete();
        }
        
        // yield return new WaitForSeconds(4.1f);

        var n = 0;
        foreach (var prefab in prefabs) {
            if (++n != 11) continue;
            if (prefab == null) continue;
            yield return new WaitForSeconds(0.1f);

            foreach (var fileInfo in compiledBundlesDirectory.GetFiles()) {
                if (!fileInfo.Name.Equals(prefab.name, StringComparison.OrdinalIgnoreCase)) continue;
                fileInfo.CopyTo($"{targetDirectory}{prefab.name}.bundle");
                break;
            }

            var obj = Instantiate(prefab, transform, false);
            // var obj = Instantiate(prefab, smol, false);
            obj.transform.localPosition = new Vector3(0, 0, 0.1f);
            obj.transform.localRotation = Quaternion.Euler(0, 180, 0);
            cam.Render();

            SaveTexture(_renderTexture, $"{targetDirectory}{prefab.name}_preview.png", 40);
            SaveTexture(_renderTexture, $"{targetDirectory}{prefab.name}_preview_clear.png", 0);

            Destroy(obj);
        }

        Debug.Log("<------");
        Debug.Log("Done!!!!!!!!");
    }

    private static void SaveTexture(RenderTexture renderTexture, string path, int blurRadius) {
        var texture2d = new Texture2D(renderTexture.width, renderTexture.height);
        RenderTexture.active = renderTexture;
        texture2d.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
        texture2d.Apply();

        if (blurRadius > 0) Blur(texture2d, blurRadius);
        ToGamma(texture2d);

        var bytes = texture2d.EncodeToPNG();
        File.WriteAllBytes(path, bytes);
        Debug.Log($"Saved to: {path}");
        Destroy(texture2d);
    }

    private static void ToGamma(Texture2D texture2d) {
        var colors = texture2d.GetPixels();

        for (var i = 0; i < colors.Length; i++) {
            var tmp = colors[i];
            tmp = tmp.gamma;
            colors[i] = tmp;
        }

        var max = 1.0f;
        for (var i = 0; i < colors.Length; i++) {
            var tmp = colors[i];
            if (tmp.r > max) max = tmp.r;
            if (tmp.g > max) max = tmp.g;
            if (tmp.b > max) max = tmp.b;
        }

        for (var i = 0; i < colors.Length; i++) {
            var tmp = colors[i];
            tmp.r /= max;
            tmp.g /= max;
            tmp.b /= max;
            tmp.a /= max;
            colors[i] = tmp;
        }

        texture2d.SetPixels(colors);
        texture2d.Apply();
    }

    private static void Blur(Texture2D texture2d, int radius) {
        var width = texture2d.width;
        var height = texture2d.height;
        var originalColors = texture2d.GetPixels();
        var blurredColors = new Color[originalColors.Length];

        var sigma = radius / 2.0f; // Standard deviation
        var twoSigmaSquare = 2 * sigma * sigma;
        var sigmaRoot = Mathf.Sqrt(twoSigmaSquare * Mathf.PI);

// Precompute Gaussian kernel weights
        var kernel = new float[2 * radius + 1, 2 * radius + 1];
        for (var y = -radius; y <= radius; y++) {
            for (var x = -radius; x <= radius; x++) {
                kernel[y + radius, x + radius] = Mathf.Exp(-(x * x + y * y) / twoSigmaSquare) / sigmaRoot;
            }
        }

// Apply the blur in parallel
        System.Threading.Tasks.Parallel.For(0, height, y => {
            for (var x = 0; x < width; x++) {
                var sumColor = Color.black;
                float alphaSum = 0;
                float weightSum = 0;

                for (var ky = -radius; ky <= radius; ky++) {
                    for (var kx = -radius; kx <= radius; kx++) {
                        var pixelX = Mathf.Clamp(x + kx, 0, width - 1);
                        var pixelY = Mathf.Clamp(y + ky, 0, height - 1);

                        var sample = originalColors[pixelY * width + pixelX];
                        var weight = kernel[ky + radius, kx + radius];

                        // Blend color in premultiplied alpha mode
                        sumColor.r += sample.r * sample.a * weight;
                        sumColor.g += sample.g * sample.a * weight;
                        sumColor.b += sample.b * sample.a * weight;
                        alphaSum += sample.a * weight;
                        weightSum += weight;
                    }
                }

                // Normalize by alpha and weight sum
                if (alphaSum > 0) {
                    sumColor.r /= alphaSum;
                    sumColor.g /= alphaSum;
                    sumColor.b /= alphaSum;
                }

                sumColor.a = alphaSum / weightSum; // Compute final alpha
                blurredColors[y * width + x] = sumColor;
            }
        });

        texture2d.SetPixels(blurredColors);
        texture2d.Apply();
    }

    private void OnDestroy() {
        _renderTexture.Release();
        Destroy(_renderTexture);
    }
}