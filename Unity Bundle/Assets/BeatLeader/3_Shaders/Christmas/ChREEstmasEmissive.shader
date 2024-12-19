Shader "Ree/ChREEstmasEmissive" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureTint ("TextureTint", Color) = (1, 1, 1, 1)
        _Glow("Glow", Range(0, 1)) = 0
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        
        Blend One Zero
        BlendOp Add

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PREVIEW_RENDERER

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _TextureTint;
            float _Glow;

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.color = v.color * _TextureTint;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 col = tex2D(_MainTex, i.uv) * i.color;

                #ifdef PREVIEW_RENDERER
                return float4(col, 1);
                #else
                return float4(col, _Glow);
                #endif
            }
            ENDCG
        }
    }
}