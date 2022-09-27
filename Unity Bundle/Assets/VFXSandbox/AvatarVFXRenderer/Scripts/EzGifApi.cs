using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

namespace VFXSandbox.AvatarVFXRenderer {
    public static class EzGifApi {
        #region CreateWebpCoroutine

        public static IEnumerator CreateWebpCoroutine(List<byte[]> rawImageData, float delaySeconds, float quality, Action<byte[]> onFinish) {
            Debug.Log("Sending frames...");
            var uploadRequest = BuildUploadRequest(rawImageData);
            yield return uploadRequest.SendWebRequest();

            Debug.Log("Making WebP...");
            var uploadData = ParseUploadResponse(uploadRequest);
            var finalizeRequest = BuildFinalizeRequest(uploadData, delaySeconds, quality);
            yield return finalizeRequest.SendWebRequest();
            
            Debug.Log("Downloading result...");
            var finalizeResult = ParseFinalizeResponse(finalizeRequest);
            var downloadRequest = BuildDownloadRequest(finalizeResult);
            yield return downloadRequest.SendWebRequest();

            Debug.Log("WebP Ready!");
            var result = ParseDownloadResponse(downloadRequest);
            onFinish(result);
        }

        #endregion

        #region DownloadRequest

        private static UnityWebRequest BuildDownloadRequest(FinalizeResult finalizeResult) {
            return UnityWebRequest.Get(finalizeResult.DownloadLink);
        }

        private static byte[] ParseDownloadResponse(UnityWebRequest downloadRequest) {
            return downloadRequest.downloadHandler.data;
        }

        #endregion

        #region FinalizeRequest
        
        private const string FinalizeEndpoint = "https://s2.ezgif.com/webp-maker/{0}?ajax=true";

        private static UnityWebRequest BuildFinalizeRequest(UploadResult uploadResult, float delaySeconds, float quality) {
            var intDelay = Mathf.RoundToInt(delaySeconds * 100);
            var intQuality = Mathf.RoundToInt(quality * 100);

            var body = new StringBuilder();
            body.Append($"file={uploadResult.FileName}");

            foreach (var file in uploadResult.Files) {
                body.Append($"&files%5B%5D={file}");
                body.Append($"&delays%5B%5D={intDelay}");
            }

            body.Append("&dfrom=1");
            body.Append("&dto=5");
            body.Append($"&delay={intDelay}");
            body.Append("&loop=");
            body.Append("&fader-delay=6");
            body.Append("&fader-frames=10");
            body.Append("&nostack=on");
            body.Append($"&percentage={intQuality}");

            var bytes = Encoding.UTF8.GetBytes(body.ToString());
            var request = new UnityWebRequest(string.Format(FinalizeEndpoint, uploadResult.FileName)) {
                method = UnityWebRequest.kHttpVerbPOST,
                uploadHandler = new UploadHandlerRaw(bytes),
                downloadHandler = new DownloadHandlerBuffer()
            };
            request.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            return request;
        }

        private static FinalizeResult ParseFinalizeResponse(UnityWebRequest finalizeRequest) {
            var body = finalizeRequest.downloadHandler.text;
            body = body.Substring(0, body.IndexOf("\" download", StringComparison.Ordinal));
            body = body.Substring(body.LastIndexOf("\"", StringComparison.Ordinal) + 1);
            return new FinalizeResult(body);
        }
        
        private class FinalizeResult {
            public readonly string DownloadLink;
            
            public FinalizeResult(string downloadLink) {
                DownloadLink = downloadLink;
            }
        }

        #endregion

        #region UploadRequest

        private const string UploadEndpoint = "https://s2.ezgif.com/webp-maker";

        private const string ContentType = "image/png";
        private static readonly IMultipartFormSection UploadFormEnding = new MultipartFormDataSection("upload", "Upload!");

        private static UnityWebRequest BuildUploadRequest(List<byte[]> rawImageData) {
            var uploadForm = rawImageData
                .Select((data, i) => new MultipartFormFileSection("files[]", data, $"frame_{i}", ContentType))
                .Append(UploadFormEnding).ToList();

            return UnityWebRequest.Post(UploadEndpoint, uploadForm);
        }

        private static UploadResult ParseUploadResponse(UnityWebRequest uploadRequest) {
            var frames = new List<string>();

            var body = uploadRequest.downloadHandler.text;
            body = body.Substring(body.IndexOf("<ul id=\"animation-frames\">", StringComparison.Ordinal));
            body = body.Substring(0, body.IndexOf("</ul", StringComparison.Ordinal));
            var split = body.Split(new[] { "\" name=\"files[]\"" }, StringSplitOptions.RemoveEmptyEntries);

            for (var i = 0; i < split.Length - 1; i++) {
                var frameName = split[i].Substring(split[i].LastIndexOf("value=\"", StringComparison.Ordinal) + 7);
                frames.Add(frameName);
            }

            var url = uploadRequest.url;
            var fileName = url.Substring(url.LastIndexOf("/", StringComparison.Ordinal) + 1);
            return new UploadResult(fileName, frames);
        }

        private class UploadResult {
            public readonly List<string> Files;
            public readonly string FileName;

            public UploadResult(string fileName, List<string> files) {
                Files = files;
                FileName = fileName;
            }
        }

        #endregion
    }
}