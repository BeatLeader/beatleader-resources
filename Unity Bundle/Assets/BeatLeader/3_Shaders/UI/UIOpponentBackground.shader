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
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 sliced_uv : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 sliced_uv : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 local_pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _BackgroundColor;
            float _FillAspect;
            float4 _ClipRect;

            v2f vert(const appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.sliced_uv = v.sliced_uv;
                o.local_pos = v.vertex.xy;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target {
                const float2 uv = i.uv;
                const float4 tex_color = tex2D(_MainTex, i.sliced_uv);
                const bool should_fill = uv.x < _FillAspect;
                float4 color = should_fill ? _Color : _BackgroundColor;
                color *= tex_color;
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(i.local_pos, _ClipRect);
                #endif
                return color;
            }
            ENDCG
        }
    }
}