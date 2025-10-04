Shader "Unlit/UIBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurScale;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
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
                    _BlurScale * _MainTex_TexelSize.x,
                    _BlurScale * _MainTex_TexelSize.y
                );

                const float2 start_uv = float2(
                    i.uv.x - step_size.x * radius,
                    i.uv.y - step_size.y * radius
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

                        result += tex2D(_MainTex, offset_uv) * weight;
                        divider += weight;
                    }
                }

                result /= divider;
                result = clamp(result, 0, 1);

                return result;
            }
            ENDCG
        }
    }
}