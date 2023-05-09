Shader "BeatLeader/Monke"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularTex ("Specular", 2D) = "white" {}
        _ReflectionColor("Reflection Color", Color) = (1,1,1,1)
        _Cube("Reflection Cubemap", Cube) = "_Skybox" {}
        _MipLevel("Reflecion Mip Level", Range(0, 9)) = 0
        _Factor("Factor", RANGE(0, 1)) = 1.0
    }

    Category
    {
        Tags{ "RenderType" = "Opaque" }

        SubShader
        {
            Pass
            {
                Cull Back
                ZWrite On

                CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_instancing
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float4 normal : NORMAL;
                    float4 uv : TEXCOORD0;

                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 uv: TEXCOORD0;
                    float4 worldPos: TEXCOORD1;
                    float4 I : TEXCOORD2;

                    UNITY_VERTEX_OUTPUT_STEREO
                };

                sampler2D _MainTex;
                sampler2D _SpecularTex;
                uniform samplerCUBE _Cube;
                float4 _ReflectionColor;
                
                float _Factor;
                float _MipLevel;
    
                v2f vert(appdata v)
                {
                    v2f o;
                    
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_OUTPUT(v2f, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    const float3 view_dir = WorldSpaceViewDir(v.vertex);
                    const float3 world_normal = UnityObjectToWorldNormal(v.normal);
                    o.I = float4( reflect(-view_dir, world_normal), _MipLevel);
                    
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    
                    return o;
                }
    
                fixed4 frag(v2f i) : SV_Target
                {
                    float4 albedo = tex2D(_MainTex, i.uv);
                    float specularity = tex2D(_SpecularTex, i.uv).x;
                    float4 col = texCUBElod(_Cube, i.I) * _ReflectionColor;
                    col = lerp(albedo, col, specularity * _Factor);
                    col.a = 0;
                    return col;
                }
    
                ENDCG
            }
        }
    }

    FallBack Off
}
