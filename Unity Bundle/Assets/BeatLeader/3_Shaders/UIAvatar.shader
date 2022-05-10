Shader "BeatLeader/UIAvatar"
{
    Properties
    {
        _AvatarTexture ("Texture", 2D) = "white" {}
        _Spinner ("Spinner", 2D) = "white" {}
        _FadeValue ("FadeValue", Range(0, 1)) = 1
        _WavesAmplitude ("WavesAmplitude", Range(0, 1)) = 1
        _BackgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        _HaloColor ("HaloColor", Color) = (1, 1, 1, 1)
        _Scale ("Scale", float) = 1.5
        _SpinnerScale ("SpinnerScale", float) = 1
        _SpinnerSpeed ("SpinnerSpeed", float) = 100
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "KeijiroNoiseCommon3D.cginc"
            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 avatar_uv : TEXCOORD0;
                float2 spinner_uv : TEXCOORD1;
                float2 relative_uv : TEXCOORD2;
            };

            sampler2D _AvatarTexture;
            float _Scale;
            float _SpinnerScale;
            float _SpinnerSpeed;
            float _FadeValue;
            float4 _BackgroundColor;
            sampler2D _Spinner;

            static const float2 offset = float2(0.5f, 0.5f);

            v2f vert (const appdata v)
            {
                float2 spinner_uv = (v.uv0 - offset) / _SpinnerScale;
                spinner_uv = rotate_uv(spinner_uv, -_Time * _SpinnerSpeed);
                spinner_uv *= _Scale;
                spinner_uv += offset;
                
                const float2 relative_uv = float2(
                   (v.uv0.x * 2 - 1) * _Scale,
                   (v.uv0.y * 2 - 1) * _Scale
                );

                const float2 avatar_uv = (relative_uv + 1) / 2;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
                o.avatar_uv = avatar_uv;
                o.spinner_uv = spinner_uv;
                o.relative_uv = relative_uv;
                return o;
            }

            static const float_range angle_fade_range = create_range(1.0, 0.96);

            float4 frag (const v2f i) : SV_Target
            {
                float fade = 1 - get_range_ratio_clamped(angle_fade_range, length(i.relative_uv));
                fade = 1 - fade * fade;

                const float4 spinner = tex2D(_Spinner, i.spinner_uv);
                const float4 avatar = tex2D(_AvatarTexture, i.avatar_uv);

                float4 col = lerp(spinner, avatar, _FadeValue);
                col = alpha_blend(col, _BackgroundColor);
                col.a *= fade * i.color.a;
                return col;
            }
            ENDCG
        }

        Pass
        {
            BlendOp Add
            Blend One One
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "KeijiroNoiseCommon3D.cginc"
            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 relative_uv : TEXCOORD2;
            };

            float _Scale;
            float _WavesAmplitude;
            float _FadeValue;
            float4 _BackgroundColor;
            float4 _RimColor;
            float4 _HaloColor;

            v2f vert (const appdata v)
            {
                const float2 relative_uv = float2(
                   (v.uv0.x * 2 - 1) * _Scale,
                   (v.uv0.y * 2 - 1) * _Scale
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
                o.relative_uv = relative_uv;
                return o;
            }

            float get_shine_value(const float distance, const float noise, const float from, const float to_static, const float to_dynamic)
            {
                const float_range range = create_range(from, to_static + to_dynamic * noise);
                return get_range_ratio_clamped(range, distance);
            }

            float get_noise_value(const float2 uv, const float_range fade_range, const float scale, const float speed, const float sharpness, const float magnitude)
            {
                float result = ClassicNoise(float3(normalize(uv) * scale, _Time.y * speed));
                result = get_range_ratio_clamped(fade_range, result);
                result = pow(result, sharpness) * magnitude;
                return result;
            }
            
            static const float static_glow = 0.04f;
            static const float_range big_noise_fade_range = create_range(-1.0, 0.6);
            static const float_range small_noise_fade_range = create_range(-0.6, 0.6);

            float4 frag (const v2f i) : SV_Target
            {
                const float big_noise = get_noise_value(i.relative_uv, big_noise_fade_range, 2.0f, 0.5f, 4.0f, 0.6f * _WavesAmplitude);
                const float small_noise = get_noise_value(i.relative_uv, small_noise_fade_range, 4.0f, 0.3f, 16.0f, 0.8f * _WavesAmplitude);
                const float glow = static_glow + big_noise + small_noise;

                const float distance = length(i.relative_uv) - 1;
                float shine = get_shine_value(distance, glow, 0.5, 0.005, 0.1);
                shine *= get_shine_value(distance, glow, -0.3, -0.001, -0.02);
                shine = pow(shine, 1 + log(1 / glow));

                const float halo_value = pow(shine, 4);
                const float rim_value = pow(shine, 9);

                float4 col = _HaloColor * halo_value;
                col += _RimColor * rim_value;
                col *= i.color.a * _FadeValue;
                return col;
            }
            ENDCG
        }
    }
}