Shader "Unlit/ChristmasTree" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _LightsMap ("LightsMap", 2D) = "white" {}
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
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _LightsMap;

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 albedo = tex2D(_MainTex, i.uv).rgb;
                float3 l = tex2D(_LightsMap, i.uv).rgb;
                l *= christmas_lights_cycle();

                float3 col = apply_fake_lights(albedo * 0.5f, i.normal);
                col += albedo * bulb_color_a * l.r;
                col += albedo * bulb_color_b * l.g;
                col += albedo * bulb_color_c * l.b;
                return float4(col, 0);
            }
            ENDCG
        }
    }
}