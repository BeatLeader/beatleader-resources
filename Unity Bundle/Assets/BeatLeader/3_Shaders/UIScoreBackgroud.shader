Shader "BeatLeader/UIScoreBackground"
{
    Properties
    {
        
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
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertex_color : COLOR;
                float2 avatar_uv : TEXCOORD0;
            };

            v2f vert (const appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.avatar_uv = v.uv0;
                return o;
            }

            static const float_range fancy_x_fade_range = create_range(0.5, 0.3);
            static const float_range y_fade_range = create_range(0.5, 0.48);

            float4 frag (const v2f i) : SV_Target
            {
                float fade = 1.0f;
                fade *= get_range_ratio_clamped(fancy_x_fade_range, abs(i.avatar_uv.x - 0.5f));
                fade *= get_range_ratio_clamped(y_fade_range, abs(i.avatar_uv.y - 0.5f));
                
                float4 col = i.vertex_color;
                col.a *= fade;
                return col;
            }
            ENDCG
        }
    }
}