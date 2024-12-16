Shader "Ree/ChREEstmasRibbon" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureTint ("TextureTint", Color) = (1, 1, 1, 1)
        _Brightness ("Brightness", Range(0, 4)) = 1
        _LightsTex("LightsTex", Cube) = "black" {}
        _ReflectionTint ("ReflectionTint", Color) = (1, 1, 1, 1)
        _ReflectionMipLevel("ReflectionMipLevel", Range(0, 9)) = 0
        _Reflectivity ("Reflectivity", Range(0, 1)) = 1
        _FresnelPower ("FresnelPower", Range(0, 10)) = 5
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
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 view_dir : TEXCOORD1;
                float3 world_pos : TEXCOORD2;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            //<-- PROPERTIES -->

            sampler2D _MainTex;
            float4 _TextureTint;
            float _Brightness;
            samplerCUBE _ReflectionTex;
            samplerCUBE _LightsTex;
            float4 _ReflectionTint;
            float _ReflectionMipLevel;
            float _FresnelPower;
            float _Reflectivity;
            float4 _TreePosition;

            //<-- VERTEX SHADER -->

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.view_dir = WorldSpaceViewDir(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            //<-- FRAGMENT SHADER -->
            fixed4 frag(v2f i) : SV_Target {
                // Calculate reflection parameters
                i.normal = normalize(i.normal);
                i.view_dir = normalize(i.view_dir);
                float3 reflection_dir = reflect(-i.view_dir, i.normal);
                float2 tree_to_fragment = normalize(_TreePosition.xz - i.world_pos.xz);
                float tree_reflection_factor = saturate(dot(reflection_dir.xz, tree_to_fragment));

                // Sample textures
                const float3 albedo = tex2D(_MainTex, i.uv) * _TextureTint * _Brightness;
                float3 diffused_lights = texCUBElod(_LightsTex, float4(reflection_dir, 5)).rgb;

                // Set lights color
                float3 cycle = christmas_lights_cycle();
                diffused_lights = get_bulb_color(diffused_lights * cycle) * tree_reflection_factor;

                // Apply Lights
                float3 col = apply_fake_lights(albedo, i.normal);
                col += apply_static_light(albedo, diffused_lights);
                return float4(col, 0);
            }
            ENDCG
        }
    }
}