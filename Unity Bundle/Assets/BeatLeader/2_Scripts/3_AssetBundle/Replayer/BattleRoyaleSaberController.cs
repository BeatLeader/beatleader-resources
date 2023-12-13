using UnityEngine;

namespace BeatLeader {
    public class BattleRoyaleSaberController : MonoBehaviour {
        #region Serialized

        [SerializeField]
        private MeshRenderer bladeRenderer;

        [SerializeField]
        private MeshRenderer handleRenderer;

        #endregion

        #region Unity Events

        private void Start() {
            _propertyBlock = new MaterialPropertyBlock();
        }

        private void Update() {
            UpdateMaterialsIfDirty();
        }

        private void OnValidate() {
            SetPropertyBlockDirty();
        }

        #endregion

        #region Properties

        [SerializeField]
        private Color coreColor = Color.red;

        public Color CoreColor {
            get => coreColor;
            set {
                if (coreColor == value) return;
                coreColor = value;
                SetPropertyBlockDirty();
            }
        }

        #endregion

        #region MaterialPropertyBlock

        private static readonly int CoreColorPropertyId = Shader.PropertyToID("_CoreColor");

        private MaterialPropertyBlock _propertyBlock;
        private bool _propertyBlockDirty = true;

        private void SetPropertyBlockDirty() {
            _propertyBlockDirty = true;
        }

        private void UpdateMaterialsIfDirty() {
            if (!_propertyBlockDirty) return;
            _propertyBlock.SetColor(CoreColorPropertyId, CoreColor);
            handleRenderer.SetPropertyBlock(_propertyBlock);
            bladeRenderer.SetPropertyBlock(_propertyBlock);
            _propertyBlockDirty = false;
        }

        #endregion
    }
}