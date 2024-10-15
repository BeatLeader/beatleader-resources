Shader "BeatLeader/UIOpponentScoreBackground"
{
    Properties
    {
        _Radius ("Edge Radius", Float) = 0.05
        _EdgeSmoothSize("Edge Smooth", Float) = 0.01
        _Color ("Color", Color) = (0, 0, 0, 0.93)
        _LinesColor ("Lines Color", Color) = (1, 1, 1, 1)
        _LineSize ("Line Size", Float) = 0.2
        _DisplayLines ("Display Lines", Int) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata {
                float2 uv : TEXCOORD1;
                float4 vertex : POSITION;
            };

            struct v2f {
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Radius;
            float _EdgeSmoothSize;
            float4 _Color;
            float4 _LinesColor;
            float _LineSize;
            bool _DisplayLines;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target {
                fixed4 color = _Color;

                if (_DisplayLines) {
                    const float uv_y = i.uv.y;
                    const float bottom_line_finish = _LineSize;
                    const float top_line_start = 1 - _LineSize;
                    if (uv_y < bottom_line_finish || uv_y > top_line_start) {
                        color = _LinesColor;
                    }
                }

                const float alpha = get_rounded_alpha(i.uv, _Radius, _EdgeSmoothSize);
                color.a *= alpha;

                return color;
            }
            ENDCG
        }
    }
}