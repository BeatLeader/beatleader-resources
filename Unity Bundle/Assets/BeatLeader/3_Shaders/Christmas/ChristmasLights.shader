Shader "Unlit/ChristmasLights" {
    Properties {
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

            #include "UnityCG.cginc"
            #include "ChristmasUtils.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata v) {
                float3 l = v.color * christmas_lights_cycle();
                float i = l.r + l.g + l.b;
                i *= i;

                float3 col;
                if (v.color.r > 0.9f) {
                    col = bulb_color_a * i;
                } else if (v.color.g > 0.9f) {
                    col = bulb_color_b * i;
                } else {
                    col = bulb_color_c * i;
                }
                
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.color = float4(col, i);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return i.color;
            }
            ENDCG
        }
    }
}