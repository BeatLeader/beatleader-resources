Shader "Unlit/StarLight" {
    Properties {
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
            #pragma multi_compile_instancing
            #pragma multi_compile _ PREVIEW_RENDERER

            #include "UnityCG.cginc"
            #include "ChristmasUtils.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float _Glow;

            v2f vert(appdata v) {
                float3 l = christmas_lights_cycle();
                float3 col = get_bulb_color(l);
                
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.color = col;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                #ifdef PREVIEW_RENDERER //ignore this keyword in ThreeJS
                return float4(1, 1, 1, 1);
                #else
                return float4(i.color, _Glow);
                #endif
            }
            ENDCG
        }
    }
}