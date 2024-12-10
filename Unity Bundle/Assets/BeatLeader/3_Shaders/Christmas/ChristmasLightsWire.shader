Shader "Unlit/ChristmasLightsWire" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
        }

        ColorMask RGB

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _Color;

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 col = float4(0, 0, 0, 0);
                col.rgb = apply_fake_lights(_Color.rgb, i.normal);
                return col;
            }
            ENDCG
        }
    }
}