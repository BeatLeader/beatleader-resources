Shader "BeatLeader/AccuracyGraphBackground"
{
    Properties
    {
        _BackgroundColor ("BackgroundColor", Color) = (1, 1, 1, 1)
        _QuarterPercentLineColor ("QuarterPercentLineColor", Color) = (1, 1, 1, 1)
        _OnePercentLineColor ("OnePercentLineColor", Color) = (1, 1, 1, 1)
        _TenPercentLineColor ("TenPercentLineColor", Color) = (1, 1, 1, 1)
        _MinutesLineColor ("MinutesLineColor", Color) = (1, 1, 1, 1)
        _SecondsLineColor ("SecondsLineColor", Color) = (1, 1, 1, 1)
        _CursorLineColor ("CursorLineColor", Color) = (1, 1, 1, 1)
        _ViewRect ("ViewRect", Vector) = (0, 0, 1, 1)
        _SongDuration ("SongDuration", Float) = 1
        _CursorPosition ("_CursorPosition", Float) = 1
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Range.cginc"
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
                float2 normalized_pos : TEXCOORD0;
            };

            float4 _BackgroundColor;

            static const float_range fade_range = create_range(0.5f, 0.48f);

            v2f vert (const appdata v)
            {
                const float2 normalized_pos = v.uv1 - float2(0.5f, 0.5f);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.normalized_pos = normalized_pos;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                float fade = get_range_ratio_clamped(fade_range, abs(i.normalized_pos.x));
                fade *= get_range_ratio_clamped(fade_range, abs(i.normalized_pos.y));
                float4 col = _BackgroundColor;
                col.a *= fade;
                return col;
            }
            ENDCG
        }

        Pass
        {
            BlendOp Add
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Range.cginc"
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
                float4 vertex_color : COLOR;
                float2 uv : TEXCOORD0;
                float2 normalized_pos : TEXCOORD1;
            };

            float4 _QuarterPercentLineColor;
            float4 _OnePercentLineColor;
            float4 _TenPercentLineColor;
            float4 _MinutesLineColor;
            float4 _SecondsLineColor;
            float4 _CursorLineColor;
            float4 _ViewRect;
            float _SongDuration;
            float _CursorPosition;
            float _FakeBloomAmount;

            static const float normalized_minute = 60.0f;
            static const float normalized_second = 1.0f;
            
            static const float normalized_percent = 1 / 100.0f;
            
            static const float_range fade_range = create_range(0.5f, 0.48f);
            static const float_range vertical_line_fade_range = create_range(0.4f, 0.46f);
            static const float_range horizontal_line_fade_range = create_range(0.4f, 0.3f);
            
            static const float_range line_fade_range = create_range(1.0f, 0.4f);
            static const float_range ten_percent_scale_range = create_range(1.0f, 4.0f);
            static const float_range one_percent_scale_range = create_range(4.0f, 20.0f);
            static const float_range dec_percent_scale_range = create_range(20.0f, 50.0f);

            v2f vert (const appdata v)
            {
                const float2 normalized_pos = v.uv1 - float2(0.5f, 0.5f);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.uv = v.uv1;
                o.normalized_pos = normalized_pos;
                o.vertex_color = v.color;
                return o;
            }

            float2 get_view_position(float4 view_rect, float2 screen_position)
            {
                return float2(
                    lerp(view_rect.x, view_rect.z, screen_position.x),
                    lerp(view_rect.y, view_rect.w, screen_position.y)
                );
            }

            float get_line_value(const float view_value, const float target_value, const float thickness)
            {
                return get_range_ratio_clamped(line_fade_range, abs(view_value - target_value) / thickness);
            }

            float get_periodic_line_value(const float view_value, const float step, const float thickness)
            {
                const float line_center = round(view_value / step) * step;
                return get_line_value(view_value, line_center, thickness);
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float2 scale = float2(1 / (_ViewRect.z - _ViewRect.x), 1 / (_ViewRect.w - _ViewRect.y));
                const float2 view_pos = get_view_position(_ViewRect, i.uv);

                const float2 line_thickness = float2(0.0024, 0.004) / scale;

                float ten_percent_line_value = get_periodic_line_value(view_pos.y, normalized_percent * 10, line_thickness.y * 1.1f);
                ten_percent_line_value *= get_range_ratio_clamped(ten_percent_scale_range, scale.y);
                float one_percent_line_value = get_periodic_line_value(view_pos.y, normalized_percent, line_thickness.y);
                one_percent_line_value *= get_range_ratio_clamped(one_percent_scale_range, scale.y);
                float dec_percent_line_value = get_periodic_line_value(view_pos.y, normalized_percent * 0.1f, line_thickness.y);
                dec_percent_line_value *= get_range_ratio_clamped(dec_percent_scale_range, scale.y);
                
                const float minutes_line_value = get_periodic_line_value(view_pos.x, normalized_minute / _SongDuration, line_thickness.x * 1.1f);
                const float seconds_line_value = get_periodic_line_value(view_pos.x, (normalized_second * 30) / _SongDuration, line_thickness.x);
                const float cursor_line_value = get_line_value(view_pos.x, _CursorPosition, line_thickness.x);
                
                float fade = get_range_ratio_clamped(fade_range, abs(i.normalized_pos.x));
                fade *= get_range_ratio_clamped(fade_range, abs(i.normalized_pos.y));

                const float vertical_line_fade = get_range_ratio_clamped(vertical_line_fade_range, abs(i.normalized_pos.y));
                const float horizontal_line_fade = get_range_ratio_clamped(horizontal_line_fade_range, abs(i.normalized_pos.y));
                
                float4 col = float4(0, 0, 0, 0);
                col = lerp(col, _SecondsLineColor, seconds_line_value * vertical_line_fade);
                col = lerp(col, _MinutesLineColor, minutes_line_value * vertical_line_fade);
                col = lerp(col, _QuarterPercentLineColor, dec_percent_line_value * horizontal_line_fade);
                col = lerp(col, _OnePercentLineColor, one_percent_line_value * horizontal_line_fade);
                col = lerp(col, _TenPercentLineColor, ten_percent_line_value * horizontal_line_fade);
                col = lerp(col, _CursorLineColor, cursor_line_value);
                col *= fade;
                return apply_fake_bloom(col, _FakeBloomAmount);
            }
            ENDCG
        }
    }
}