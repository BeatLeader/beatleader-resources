Shader "Unlit/UIBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _BlurScale ("BlurScale", Float) = 1
    }
    
    SubShader {
        Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "PreviewType" = "Plane"
        }
        
        GrabPass {
            "_GrabTex"
        }

        Pass {
            ColorMask RGB
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_local BLUR_10 BLUR_20 BLUR_40

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 grab_uv : TEXCOORD0;
                float2 mask_uv : TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex;
            sampler2D _GrabTex;
            float4 _GrabTex_TexelSize;
            float _BlurScale;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.grab_uv = ComputeGrabScreenPos(o.vertex);
                o.mask_uv = v.uv1;
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

            fixed4 frag (v2f i) : SV_Target {
                const float2 step_size = float2(
                    _BlurScale * _GrabTex_TexelSize.x,
                    _BlurScale * _GrabTex_TexelSize.y
                );
                
                const float2 start_uv = float2 (
                    i.grab_uv.x / i.grab_uv.w - step_size.x * radius,
                    i.grab_uv.y / i.grab_uv.w - step_size.y * radius
                );
                
                float4 mask = tex2D(_MainTex, i.mask_uv);
                if (mask.a <= 0) discard;
                
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
                        
                        result += tex2D(_GrabTex, offset_uv) * weight;
                        divider += weight;
                    }
                }

                result /= divider;
                result = clamp(result, 0, 1);
                result *= tex2D(_MainTex, i.mask_uv) * _Tint;
                result.a = mask.a;
                return result;
            }
            ENDCG
        }
    }
}
