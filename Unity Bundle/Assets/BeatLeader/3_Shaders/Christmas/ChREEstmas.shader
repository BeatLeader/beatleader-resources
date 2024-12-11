Shader "Ree/ChREEstmas" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TextureTint ("TextureTint", Color) = (1, 1, 1, 1)

        _ReflectionTex("ReflectionTex", Cube) = "_Skybox" {}
        _LightsTex("LightsTex", Cube) = "black" {}
        _ReflectionTint ("ReflectionTint", Color) = (1, 1, 1, 1)
        _ReflectionMipLevel("ReflectionMipLevel", Range(0, 9)) = 0
        _ReflectionFactor("ReflectionFactor", Range(0, 1)) = 0.5
        _ReflectionFresnel("ReflectionFresnel", Range(0, 3)) = 1
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
                float4 I : TEXCOORD1;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _TextureTint;

            samplerCUBE _ReflectionTex;
            samplerCUBE _LightsTex;
            float4 _ReflectionTint;
            float _ReflectionMipLevel;
            float _ReflectionFactor;
            float _ReflectionFresnel;

            v2f vert(appdata v) {
                const float3 view_dir = normalize(WorldSpaceViewDir(v.vertex));
                const float3 world_normal = normalize(UnityObjectToWorldNormal(v.normal));
                float fnl = dot(view_dir, world_normal);
                fnl *= fnl > 0;

                fnl = smoothstep(0, 1, pow(1 - fnl, 1 / _ReflectionFresnel));

                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;

                o.I.xyz = reflect(-view_dir, world_normal);
                o.I.w = fnl * _ReflectionFactor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 cycle = christmas_lights_cycle();

                const float3 albedo = tex2D(_MainTex, i.uv) * _TextureTint;
                const float3 specular = texCUBElod(_LightsTex, float4(i.I.xyz, _ReflectionMipLevel)).rgb * cycle;
                const float3 diffuse = texCUBElod(_LightsTex, float4(i.I.xyz, 5)).rgb * cycle;

                float3 diffuse_light_color = get_bulb_color(diffuse);

                float3 reflection_col = get_bulb_color(specular) * _ReflectionTint;

                float glow = reflection_col.r + reflection_col.g + reflection_col.b;
                glow *= i.I.w;
                glow *= glow;
                
                // reflection_col += texCUBElod(_ReflectionTex, float4(i.I.xyz, _ReflectionMipLevel)) * _ReflectionTint;

                float3 col = apply_fake_lights(albedo, normalize(i.normal));
                col += apply_static_light(albedo, diffuse_light_color);
                col.rgb = lerp(col.rgb, reflection_col, i.I.w);
                return float4(col, glow);
            }
            ENDCG
        }
    }
}