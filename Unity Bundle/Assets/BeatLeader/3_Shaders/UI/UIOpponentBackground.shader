Shader "BeatLeader/UIOpponentBackground"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _BackgroundColor("BackgroundColor", Color) = (0, 0, 0, 0)
        _FillAspect("FillAspect", Float) = 1
        _MainTex ("Texture", 2D) = "White" {}
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

            struct appdata {
                float2 uv : TEXCOORD1;
                float2 sliced_uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f {
                float2 uv : TEXCOORD1;
                float2 sliced_uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _BackgroundColor;
            float _FillAspect;

            v2f vert(const appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.sliced_uv = v.sliced_uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target {
                const float2 uv = i.uv;
                const float4 tex_color = tex2D(_MainTex, i.sliced_uv);
                const bool should_fill = uv.x < _FillAspect;
                const float4 color = should_fill ? _Color : _BackgroundColor;
                return color * tex_color;
            }
            ENDCG
        }
    }
}