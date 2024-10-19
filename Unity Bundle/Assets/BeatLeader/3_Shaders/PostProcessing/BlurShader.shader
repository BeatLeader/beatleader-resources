Shader "Unlit/UIBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OverlayTex ("Post-Process Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _Overlay ("Overlay", Color) = (0, 0, 0, 0)
        _BlurScale ("BlurScale", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "PreviewType" = "Plane"
        }

        Pass
        {
            Cull Off
            ZWrite Off
            ZTest Always
            Blend One Zero
            ColorMask RGBA

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local BLUR_10

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 grab_uv : TEXCOORD0;
                float2 mask_uv : TEXCOORD1;
                float2 local_pos : TEXCOORD2;
            };

            float4 _Tint;
            float4 _Overlay;
            sampler2D _MainTex;
            sampler2D _OverlayTex;
            float4 _OverlayTex_TexelSize;
            float _BlurScale;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grab_uv = v.uv0;
                o.mask_uv = v.uv0;
                o.local_pos = v.vertex.xy;
                return o;
            }

            #ifdef BLUR_40
            static const int radius = 40;
            #else

            #ifdef BLUR_20
            static const int radius = 20;
            #else
            static const int radius = 10;
            #endif

            #endif

            static const int iterations = radius * 2;

            fixed4 frag(v2f i) : SV_Target {
                const float2 step_size = float2(
                    _BlurScale * _OverlayTex_TexelSize.x,
                    _BlurScale * _OverlayTex_TexelSize.y
                );

                const float2 start_uv = float2(
                    i.grab_uv.x - step_size.x * radius,
                    i.grab_uv.y - step_size.y * radius
                );

                float4 result = float4(0, 0, 0, 0);
                float divider = 0.0f;

                float2 offset = float2(0, 0);

                for (int x = 0; x <= iterations; x++) {
                    offset.x = x - radius;

                    for (int y = 0; y < iterations; y++) {
                        offset.y = y - radius;
                        float weight = 1.0f - length(offset) / radius;
                        if (weight <= 0) continue;

                        weight = smoothstep(0, 1, weight);

                        const float2 offset_uv = float2(
                            start_uv.x + step_size.x * x,
                            start_uv.y + step_size.y * y
                        );

                        result += tex2D(_OverlayTex, offset_uv) * weight;
                        divider += weight;
                    }
                }

                result /= divider;
                result = clamp(result, 0, 1);
                result *= _Tint;
                result += _Overlay;

                return result;
            }
            ENDCG
        }
    }
}