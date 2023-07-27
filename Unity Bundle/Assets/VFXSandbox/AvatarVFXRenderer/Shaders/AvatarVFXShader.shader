Shader "VFXSandbox/AvatarVFXShader"
{
    Properties
    {
        _Scale ("Scale", float) = 1.5
        [HDR] _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        [HDR] _HaloColor ("HaloColor", Color) = (1, 1, 1, 1)
        
        _Blend ("Blend", Range(0, 1)) = 0.0

        _Speed ("Speed", float) = 0.5
        _DropOff ("Speed", float) = 0.0
        
        _WavesAmplitude ("WavesAmplitude", Range(0, 2)) = 1
        _WavesConfig ("WavesConfig", Vector) = (0.04, 0.6, 0.8, 1.0)
        
        _DetailsNoiseRamp ("DetailsNoiseRamp", Vector) = (-1.0, 1.0, 1.0, 1.0)
        _DetailsInRamp ("DetailsInRamp", Vector) = (0.8, 1.0, 1.0, 1.0)
        _DetailsOutRamp ("DetailsOutRamp", Vector) = (1.5, 1.0, 1.0, 1.0)
        _DetailsConfig0 ("DetailsConfig0", Vector) = (4.0, 1.0, 0.0, 1.0)
        _DetailsConfig1 ("DetailsConfig1", Vector) = (0.0, 0.0, 1.0, 1.0)
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "PreviewType" = "Plane"
        }
        
        Cull Off
        Blend One Zero

        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"
            #include "Assets/BeatLeader/3_Shaders/Avatars/UIShinyAvatar.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 relative_uv : TEXCOORD2;
            };

            float _Scale;
            
            float _TimeOffsetA;
            float _TimeOffsetB;
            float _Blend;
            float _IsRendering;

            float _Speed;
            float _DropOff;
            
            float4 _RimColor;
            float4 _HaloColor;

            v2f vert (const appdata v)
            {
                const float2 relative_uv = float2(
                   (v.uv.x * 2 - 1) * _Scale,
                   (v.uv.y * 2 - 1) * _Scale
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.relative_uv = relative_uv;
                return o;
            }
            
            float3 normalize_rgb(float3 rgb)
            {
                rgb = clamp(rgb, 0, 1);
                float3 HSV = RGBtoHSV(rgb);
                HSV.z = 1.0;
                return HSVtoRGB(HSV);
            }

            float4 get_color(const v2f i, const float time)
            {
                const float waves = get_waves_value_with_speed(i.relative_uv, time, _Speed);
                const float details = get_details_value(i.relative_uv, time);
                const float shine = (waves + details) * (_DropOff > 0 ? -i.relative_uv.y * _DropOff : 1.0);

                const float halo_value = pow(shine, 4);
                const float rim_value = pow(shine, 9);
                const float alpha = pow(halo_value + rim_value, 0.4545454545);

                float4 col = _HaloColor * halo_value;
                col += _RimColor * rim_value;
                col.rgb = lerp(col.rgb, normalize_rgb(col.rgb), _IsRendering);
                col.a = lerp(1.0f, alpha, _IsRendering);
                return col;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float4 col_a = get_color(i, _TimeOffsetA);
                const float4 col_b = get_color(i, _TimeOffsetB);
                return lerp(col_a, col_b, _Blend);
            }
            ENDCG
        }
    }
}