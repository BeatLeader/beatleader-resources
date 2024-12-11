Shader "Ree/ChREEstmasRibbon" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureTint ("TextureTint", Color) = (1, 1, 1, 1)
        _LightsTex("LightsTex", Cube) = "black" {}
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        
        Blend One Zero
        BlendOp Add
        Cull Off

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
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 I : TEXCOORD1;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _TextureTint;
            samplerCUBE _LightsTex;

            v2f vert(appdata v) {
                const float3 view_dir = normalize(WorldSpaceViewDir(v.vertex));
                const float3 world_normal = normalize(UnityObjectToWorldNormal(v.normal));

                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.I = reflect(-view_dir, world_normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 cycle = christmas_lights_cycle();

                const float3 albedo = tex2D(_MainTex, i.uv) * _TextureTint;
                const float3 diffuse = texCUBElod(_LightsTex, float4(i.I, 5)).rgb * cycle;
                float3 diffuse_light_color = get_bulb_color(diffuse);

                float3 col = apply_fake_lights(albedo, normalize(i.normal));
                col += apply_static_light(albedo, diffuse_light_color);
                return float4(col, 0.0);
            }
            ENDCG
        }
    }
}