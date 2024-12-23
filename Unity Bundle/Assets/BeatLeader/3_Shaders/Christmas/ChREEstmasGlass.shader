Shader "Ree/ChREEstmasGlass" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureTint ("TextureTint", Color) = (1, 1, 1, 1)
        _Brightness ("Brightness", Range(0, 4)) = 1
        _Alpha ("Alpha", Range(0, 1)) = 0

        _ReflectionTex("ReflectionTex", Cube) = "_Skybox" {}
        _LightsTex("LightsTex", Cube) = "black" {}
        _ReflectionTint ("ReflectionTint", Color) = (1, 1, 1, 1)
        _ReflectionMipLevel("ReflectionMipLevel", Range(0, 9)) = 0
        _Reflectivity ("Reflectivity", Range(0, 1)) = 1
        _FresnelPower ("FresnelPower", Range(0, 10)) = 5
    }

    SubShader {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        BlendOp Add
        ColorMask RGB
//        ColorMask RGBA

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
                float3 color : COLOR;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 view_dir : TEXCOORD1;
                float3 world_pos : TEXCOORD2;
                float3 christmas_lights_cycle : TEXCOORD3;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            //<-- PROPERTIES -->

            sampler2D _MainTex;
            float4 _TextureTint;
            float _Brightness;
            float _Alpha;
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
                o.christmas_lights_cycle = christmas_lights_cycle();
                o.color = v.color * _TextureTint * _Brightness;
                o.uv = v.uv;
                return o;
            }

            //<-- FRAGMENT SHADER -->
            float3 get_env_color(const float4 cubemap_coords, const float3 tree_direction, const float3 lights_cycle) {
                float tree_direction_factor = saturate(dot(normalize(cubemap_coords.xz), normalize(tree_direction.xz)));
                float3 a = texCUBElod(_ReflectionTex, cubemap_coords).rgb;
                float3 b = texCUBElod(_LightsTex, cubemap_coords).rgb;
                b = get_bulb_color(b * lights_cycle);
                return lerp(a, b, tree_direction_factor);
            }

            fixed4 frag(v2f i) : SV_Target {
                // Calculate parameters
                i.normal = normalize(i.normal);
                i.view_dir = normalize(i.view_dir);
                float3 reflection_dir = reflect(-i.view_dir, i.normal);
                float3 tree_dir = normalize(_TreePosition - i.world_pos);
                float reflectivity = pow(1.0 - saturate(dot(i.view_dir, i.normal)), _FresnelPower);
                reflectivity = lerp(0.04, 1.0, reflectivity) * _Reflectivity;

                // Calculate color
                const float3 albedo = tex2D(_MainTex, i.uv) * i.color;
                const float3 diffuse = get_env_color(float4(i.normal, 6), tree_dir, i.christmas_lights_cycle);
                const float3 specular = get_env_color(float4(reflection_dir, _ReflectionMipLevel), tree_dir, i.christmas_lights_cycle);

                float3 col = apply_fake_lights(albedo, i.normal);
                col += apply_static_light(albedo, diffuse);
                col = lerp(col, specular * _ReflectionTint, reflectivity);

                float alpha = lerp(_Alpha, 1, reflectivity * reflectivity);
                return float4(col, alpha);
            }
            ENDCG
        }
    }
}