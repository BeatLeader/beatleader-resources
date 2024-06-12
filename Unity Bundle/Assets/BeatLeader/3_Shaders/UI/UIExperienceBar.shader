Shader "BeatLeader/UIExperienceBar"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Focus ("Focus", Range(0, 1)) = 0
        _Progress ("Progress", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Cull Off
        ZWrite Off

        Pass
        {
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            float4 _Color;
            float _Focus;
            float _Progress;

            static const float border_half_width = 0.3f;
            static const float2 track_power = float2(30, 7);

            v2f vert(const appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.uv0 = v.uv0;
                return o;
            }

            float4 frag(const v2f i) : SV_Target {
                const float2 uv_focus = float2(0.95 + _Focus * 0.01, 0.7 + _Focus * 0.15);
                const float2 uv = i.uv0 / uv_focus;

                float4 track_color = _Color;
                track_color = uv.x >= _Progress ? track_color * 0.2 : track_color;
                float4 border_color = _Color;
                border_color.rgb += 0.4;

                const float2 super_uv = (i.uv0 - 0.5) * 2 / uv_focus;
                const float track_distance = get_signed_super_ellipse_distance(super_uv, track_power);
                const float a = (track_distance - 1 + border_half_width) / border_half_width;

                const float track_value = a < 0;
                const float border_value = smoothstep(0, 1, 1 - abs(a));

                border_color = lerp(border_color * 0.8, float4(1, 1, 1, 1), _Focus);

                float4 col = float4(0, 0, 0, 0);
                col = lerp(col, track_color, track_value);
                col = lerp(col, border_color, border_value);

                return col;
            }
            ENDCG
        }
    }
}