using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using BeatLeader.Themes;
using UnityEngine;
using Random = UnityEngine.Random;

namespace VFXSandbox.AvatarVFXRenderer {
    [RequireComponent(typeof(MeshRenderer))]
    public class VFXRenderer : MonoBehaviour {
        #region Serialized

        [SerializeField]
        private ThemesCollection themesCollection;

        [SerializeField]
        private ThemePreviewController themePreviewController;

        [Header("<---------- THEME ------------>"), SerializeField]
        private ThemeType themeType;

        [SerializeField]
        private ThemeTier themeTier;

        [SerializeField]
        private OutputType outputType;

        [Header("<---------- OUTPUT ------------>"), SerializeField]
        private bool render;

        [SerializeField]
        private string outputDirectory;

        [SerializeField]
        private int fps;

        [SerializeField]
        private float outputTimeSeconds;

        [SerializeField]
        private float previewTimeSeconds;

        [SerializeField]
        private float fadeTimeSeconds;

        [Header("<---------- QUALITY ------------>"), SerializeField]
        private Vector2 renderSize = new Vector2(512, 512);

        [SerializeField]
        private Vector2 outputSize = new Vector2(256, 256);

        [SerializeField, Range(0, 1)]
        private float previewScale = 0.5f;

        [SerializeField, Range(0, 1)]
        private float smallAvatarScale = 0.25f;

        [SerializeField, Range(0, 1)]
        private float outputQuality = 0.9f;

        [SerializeField, Range(0, 1)]
        private float previewQuality = 0.6f;

        #endregion

        #region Properties

        private Vector2 RenderSize {
            get {
                switch (outputType) {
                    case OutputType.AvatarFull: return renderSize;
                    case OutputType.AvatarSmall: return renderSize * smallAvatarScale;
                    case OutputType.AvatarPreview: return renderSize * previewScale;
                    default: throw new ArgumentOutOfRangeException();
                }
            }
        }

        private Vector2 OutputSize {
            get {
                switch (outputType) {
                    case OutputType.AvatarFull: return outputSize;
                    case OutputType.AvatarSmall: return outputSize * smallAvatarScale;
                    case OutputType.AvatarPreview: return outputSize * previewScale;
                    default: throw new ArgumentOutOfRangeException();
                }
            }
        }

        private float Quality => (outputType is OutputType.AvatarPreview) ? outputQuality : previewQuality;
        private float TotalTime => (outputType is OutputType.AvatarPreview) ? previewTimeSeconds : outputTimeSeconds;
        private float TotalFrames => fps * TotalTime;
        private float SecondsPerFrame => 1.0f / fps;

        #endregion

        #region OnValidate

        public void OnValidate() {
            if (themePreviewController == null) return;
            themePreviewController.SetTheme(themeType);
        }

        #endregion

        #region Start

        private static readonly int IsRenderingPropertyId = Shader.PropertyToID("_IsRendering");
        private static readonly int NoiseOffsetPropertyId = Shader.PropertyToID("_NoiseOffset");

        private MeshRenderer _previewRenderer;
        private Material _material;

        private RenderTexture _tempBuffer;
        private RenderTexture _renderBuffer;
        private RenderTexture _outputBuffer;

        private void Start() {
            Shader.SetGlobalVector(NoiseOffsetPropertyId, Random.insideUnitSphere * 10f);

            _tempBuffer = new RenderTexture(1, 1, 0, RenderTextureFormat.Default);
            _tempBuffer.Create();

            _renderBuffer = new RenderTexture((int)RenderSize.x, (int)RenderSize.y, 0, RenderTextureFormat.Default);
            _renderBuffer.Create();

            _outputBuffer = new RenderTexture((int)OutputSize.x, (int)OutputSize.y, 0, RenderTextureFormat.Default);
            _outputBuffer.Create();

            themesCollection.TryGetThemeMaterials(themeType, out var materials);
            materials.TryGetAvatarMaterial(themeTier, outputType is OutputType.AvatarSmall, out _material);

            _previewRenderer = GetComponent<MeshRenderer>();
            _previewRenderer.material.mainTexture = _renderBuffer;
        }

        private void OnDestroy() {
            Shader.SetGlobalVector(NoiseOffsetPropertyId, Vector4.zero);
            _previewRenderer.material.mainTexture = null;
            _tempBuffer.Release();
            _renderBuffer.Release();
            _outputBuffer.Release();
        }

        #endregion

        #region Update

        private static readonly int TimeOffsetAPropertyId = Shader.PropertyToID("_TimeOffsetA");
        private static readonly int TimeOffsetBPropertyId = Shader.PropertyToID("_TimeOffsetB");
        private static readonly int BlendPropertyId = Shader.PropertyToID("_Blend");

        private readonly List<byte[]> _frames = new List<byte[]>();
        private int _state;

        private void Update() {
            if (!render) _state = 2;

            switch (_state) {
                case 0: //Render
                    _frames.Add(RenderPng());
                    if (_frames.Count >= TotalFrames) _state += 1;
                    break;
                case 1: //Save
                    MakeWebP();
                    _state += 1;
                    break;
                default: //Preview
                    RenderPreview();
                    break;
            }
        }

        #endregion

        #region Save

        private void MakeWebP() {
            StartCoroutine(EzGifApi.CreateWebpCoroutine(_frames, SecondsPerFrame, Quality, OnWebPReady));
        }

        private void OnWebPReady(byte[] data) {
            var filePath = Path.Combine(outputDirectory, GetFileName());
            if (!Directory.Exists(outputDirectory)) Directory.CreateDirectory(outputDirectory);
            File.WriteAllBytes(filePath, data);
            Debug.Log($"File saved: {filePath}");
        }

        private string GetFileName() {
            var sb = new StringBuilder();
            sb.Append(themeType.ToString());
            sb.Append("_");
            sb.Append(themeTier.ToString());
            switch (outputType) {
                case OutputType.AvatarFull: break;
                case OutputType.AvatarSmall:
                    sb.Append("_small");
                    break;
                case OutputType.AvatarPreview:
                    sb.Append("_preview");
                    break;
                default: throw new ArgumentOutOfRangeException();
            }

            sb.Append(".webp");
            return sb.ToString();
        }

        #endregion

        #region RenderPng

        private byte[] RenderPng() {
            Shader.SetGlobalFloat(IsRenderingPropertyId, render ? 1.0f : 0.0f);

            var timeA = _frames.Count * SecondsPerFrame;
            var timeB = timeA - TotalTime;
            var blend = Mathf.Clamp01(timeA / fadeTimeSeconds);

            Shader.SetGlobalFloat(TimeOffsetAPropertyId, timeA);
            Shader.SetGlobalFloat(TimeOffsetBPropertyId, timeB);
            _material.SetFloat(BlendPropertyId, blend);

            Graphics.Blit(_tempBuffer, _renderBuffer, _material);
            Graphics.Blit(_renderBuffer, _outputBuffer);
            return RenderTextureToPngBytes(_outputBuffer);
        }

        private static byte[] RenderTextureToPngBytes(RenderTexture tex) {
            RenderTexture.active = tex;

            var texture = new Texture2D(tex.width, tex.height, TextureFormat.RGBAFloat, false, true);
            texture.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
            texture.Apply();

            var bytes = texture.EncodeToPNG();
            Destroy(texture);
            return bytes;
        }

        #endregion

        #region RenderPreview

        private void RenderPreview() {
            Shader.SetGlobalFloat(IsRenderingPropertyId, 0.0f);
            Shader.SetGlobalFloat(TimeOffsetAPropertyId, Time.time);
            _material.SetFloat(BlendPropertyId, 0.0f);
            Graphics.Blit(_tempBuffer, _renderBuffer, _material);
        }

        #endregion
    }
}