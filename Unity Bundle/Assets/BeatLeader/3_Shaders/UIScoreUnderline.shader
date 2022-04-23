Shader "BeatLeader/UIScoreUnderline"
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
        BlendOp Add
        Blend One One

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

            static const float_range y_remap_range = create_range(0.0, 0.05);
            static const float_range x_fade_range = create_range(0.5, 0.44);
            static const float_range y_fade_range = create_range(0.5, 0.3);

            v2f vert (const appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.avatar_uv = float2(v.uv0.x, get_range_ratio(y_remap_range, pow(v.uv0.y, 222)));
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                float fade = 1.0f;
                fade *= get_range_ratio_clamped(x_fade_range, abs(i.avatar_uv.x - 0.5f));
                fade *= get_range_ratio_clamped(y_fade_range, abs(i.avatar_uv.y - 0.5f));
                return i.vertex_color * fade;
            }
            ENDCG
        }
    }
}