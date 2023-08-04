Shader "BeatLeader/UIShinyAvatar"
{
    Properties
    {
        [NoScaleOffset] _AvatarTexture ("Texture", 2D) = "white" {}
        [NoScaleOffset] _Spinner ("Spinner", 2D) = "white" {}
        _FadeValue ("FadeValue", Range(0, 1)) = 1
        
        _Scale ("Scale", float) = 1.5
        _BackgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
        [HDR] _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        [HDR] _HaloColor ("HaloColor", Color) = (1, 1, 1, 1)
        _HueShift ("HueShift", Range(0, 6.28318530718)) = 0
        _Saturation ("Saturation", Range(0, 2)) = 1 

        _Speed ("Speed", float) = 0.5
        _DropOff ("Speed", float) = 0.0
        
        _WavesConfig ("WavesConfig", Vector) = (0.04, 0.6, 0.8, 1.0)
        _DetailsNoiseRamp ("DetailsNoiseRamp", Vector) = (-1.0, 1.0, 1.0, 1.0)
        _DetailsInRamp ("DetailsInRamp", Vector) = (0.8, 1.0, 1.0, 1.0)
        _DetailsOutRamp ("DetailsOutRamp", Vector) = (1.5, 1.0, 1.0, 1.0)
        _DetailsConfig0 ("DetailsConfig0", Vector) = (1.0, 0.1, 10.0, 0.0)
        _DetailsConfig1 ("DetailsConfig1", Vector) = (0.0, 0.0, 0.0, 0.0)
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

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"
            #include "AvatarShared.cginc"
            ENDCG
        }

            Pass
        {
            BlendOp Add
            Blend One One
//            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex avatar_vertex_shader
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"
            #include "AvatarShared.cginc"
            #include "UIShinyAvatar.cginc"

            float4 _RimColor;
            float4 _HaloColor;
            float _HueShift;
            float _Saturation;

            float _Speed;
            float _DropOff;

            float4 frag (const v2f i) : SV_Target
            {
                const float waves = get_waves_value_with_speed(i.relative_uv, _Time.y, _Speed);
                const float details = get_details_value(i.relative_uv, _Time.y);
                const float shine = (waves + details) * (_DropOff > 0 ? -i.relative_uv.y * _DropOff : 1.0);

                const float halo_value = pow(shine, 4);
                const float rim_value = pow(shine, 9);

                float4 col = _HaloColor * halo_value + _RimColor * rim_value;
                col.rgb = transform_rgb(clamp(col.rgb, 0, 1), _HueShift, _Saturation, 0.0);
                col *= i.color.a;
                return col;
            }
            ENDCG
        }
    }
}