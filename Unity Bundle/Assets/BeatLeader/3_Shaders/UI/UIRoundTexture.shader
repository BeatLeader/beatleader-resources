Shader "BeatLeader/UIRoundTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Edge Radius", Float) = 0.1
        _EdgeSmoothSize ("Edge Smooth", Float) = 0.01
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        ZWrite Off
        ZTest Always
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _Radius;
            float _EdgeSmoothSize;

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i): SV_Target {
                const float alpha = get_rounded_alpha(i.uv, _Radius, _EdgeSmoothSize);

                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= alpha;

                return col;
            }
            ENDCG
        }
    }
}