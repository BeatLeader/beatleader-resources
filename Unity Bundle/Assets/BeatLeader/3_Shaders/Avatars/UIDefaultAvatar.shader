﻿Shader "BeatLeader/UIDefaultAvatar"
{
    Properties
    {
        [NoScaleOffset] _AvatarTexture ("Texture", 2D) = "white" {}
        [NoScaleOffset] _Spinner ("Spinner", 2D) = "white" {}
        _FadeValue ("FadeValue", Range(0, 1)) = 1
        _Scale ("Scale", float) = 1.5
        _BackgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "PreviewType" = "Plane"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex avatar_vertex_shader
            #pragma fragment avatar_fragment_shader
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT

            #include "AvatarShared.cginc"
            ENDCG
        }
    }
}