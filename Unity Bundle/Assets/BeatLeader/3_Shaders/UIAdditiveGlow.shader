Shader "Ree/UIAdditiveGlow"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off
        BlendOp Add
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "utils.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 avatar_uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (const appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.avatar_uv = v.uv0;
                o.color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float4 tex = tex2D(_MainTex, i.avatar_uv);
                const float glow = i.color.a * tex.a;
                float3 col = i.color.rgb * tex.rgb * glow;
                return float4(col, pow(glow, 2.0f));
            }
            ENDCG
        }
    }
}