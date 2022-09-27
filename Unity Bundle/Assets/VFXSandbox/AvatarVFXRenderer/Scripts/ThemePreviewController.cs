using BeatLeader.Themes;
using UnityEngine;

namespace VFXSandbox.AvatarVFXRenderer {
    public class ThemePreviewController : MonoBehaviour {
        #region Serialized

        [SerializeField]
        private ThemesCollection themesCollection;

        [SerializeField]
        private MeshRenderer tier1AvatarFull;

        [SerializeField]
        private MeshRenderer tier1AvatarSmall;

        [SerializeField]
        private MeshRenderer tier2AvatarFull;

        [SerializeField]
        private MeshRenderer tier2AvatarSmall;

        [SerializeField]
        private MeshRenderer tier3AvatarFull;

        [SerializeField]
        private MeshRenderer tier3AvatarSmall;

        #endregion

        #region SetTheme

        public void SetTheme(ThemeType themeType) {
            if (!themesCollection.TryGetThemeMaterials(themeType, out var materials)) return;
            tier1AvatarFull.material = materials.tier1AvatarFull;
            tier1AvatarSmall.material = materials.tier1AvatarSmall;
            tier2AvatarFull.material = materials.tier2AvatarFull;
            tier2AvatarSmall.material = materials.tier2AvatarSmall;
            tier3AvatarFull.material = materials.tier3AvatarFull;
            tier3AvatarSmall.material = materials.tier3AvatarSmall;
        }

        #endregion
    }
}