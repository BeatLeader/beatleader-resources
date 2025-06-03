Shader "BeatLeader/UIExperienceBar"
{
    Properties
    {
        _CurrentExpColor ("Current Exp Color", Color) = (0.5, 0, 0.5, 1)
        _SessionExpColor ("Session Exp Color", Color) = (0.0, 0.7, 0.0, 1)
        _MissingExpColor ("Missing Exp Color", Color) = (0.2, 0.2, 0.2, 1)
        _HighlightColor ("Highlight Tint", Color) = (0, 0, 0.3, 1)
        _GradientT ("Gradient Lerp Factor", Range(0, 1)) = 0.0

        _ExpProgress ("Current Experience", Range(0,1)) = 0.4
        _SessionProgress ("Session Experience", Range(0,1)) = 0.2
        _Highlight ("Highlight", Float) = 0

        _PowerX ("PowerX", Float) = 9
        _PowerY ("PowerY", Float) = 6
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 vertex_color : COLOR;
                float2 uv : TEXCOORD0;
                
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _CurrentExpColor;
            fixed4 _SessionExpColor;
            fixed4 _MissingExpColor;
            fixed4 _HighlightColor;
            float _GradientT;
            float _ExpProgress;
            float _SessionProgress;
            float _Highlight;

            float _PowerX;
            float _PowerY;

           v2f vert(const appdata v) {
               const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;

                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.uv = scaled_uv;
                return o;
            }

            float get_super_ellipse_distance_to_circle(float2 on_circle)
            {
                const float2 on_ellipse = float2(
                    pow(abs(on_circle.x), _PowerX),
                    pow(abs(on_circle.y), _PowerY)
                );
                
                return 1 - length(on_ellipse);
            }

            static const float_range alpha_range = create_range(0.0f, 0.1f);

            fixed4 frag (const v2f i) : SV_Target
            {
                float x = i.uv.x;

                fixed4 color;
                if (x + 1 < _ExpProgress * 2)
                {
                    color = _CurrentExpColor;
                }
                else if (x + 1 < (_ExpProgress + _SessionProgress) * 2)
                {
                    float wave = sin((i.uv.x + i.uv.y + _Time.y * 0.5) * 10.0) * 0.1;
                    color = lerp(_CurrentExpColor, _SessionExpColor, _GradientT);
                    color = color + wave;
                    color = saturate(color);
                }
                else
                {
                    color = _MissingExpColor;
                }

                if (_Highlight > 0.5)
                {
                    color = lerp(color, _HighlightColor, 0.3);
                }

                const float distance = get_super_ellipse_distance_to_circle(i.uv);
                const float alpha = get_range_ratio_clamped(alpha_range, distance);

                float4 col = i.vertex_color * color;
                col.a *= alpha * i.vertex_color.a;

                return col;
            }
            ENDCG
        }
    }
}