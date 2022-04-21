Shader "BeatLeader/HandAccIndicator"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FillValue ("FillValue", Range(0, 1)) = 1
        _Thickness ("Thickness", Range(0, 1)) = 1
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            float4 _Color;
            float _FillValue;
            float _Thickness;
            
            v2f vert (const appdata v)
            {
                float2 spinner_uv = (v.uv0 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
                o.uv = spinner_uv;
                return o;
            }

            static const float max_angle = UNITY_PI * 1.05f;
            static const float_range angle_fade_range = create_range( 0.0f, -0.03);
            static const float_range length_fade_range = create_range( 0.0f, -0.02);

            float4 frag (const v2f i) : SV_Target
            {
                const float angle = atan2(i.uv.y, abs(i.uv.x)) + UNITY_HALF_PI - max_angle * _FillValue;
                const float distance = abs(1 - length(i.uv) - _Thickness) - _Thickness;
                
                float fade = get_range_ratio_clamped(angle_fade_range, angle);
                fade *= get_range_ratio_clamped(length_fade_range, distance);
                
                float4 col = _Color;
                col.a *= fade * i.color.a;
                return col;
            }
            ENDCG
        }
    }
}