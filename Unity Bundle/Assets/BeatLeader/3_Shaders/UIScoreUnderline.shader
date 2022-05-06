Shader "BeatLeader/UIScoreUnderline"
{
    Properties
    {
        _IdleColor("IdleColor", Color) = (1, 1, 1, 1)
        _HighlightColor("HighlightColor", Color) = (1, 1, 1, 1)
        _Waves ("Waves", Range(0, 1)) = 1
        _Seed ("Seed", Range(0, 1)) = 1
        _HighlightTest ("HighlightTest", Range(0, 1)) = 1
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
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "KeijiroNoiseCommon3D.cginc"
            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"
            #include "ScoreUnderline.cginc"

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
            };
            
            float4 _IdleColor;
            float4 _HighlightColor;
            float _Waves;
            float _Seed;
            float _HighlightTest;

            static const float vertical_offset = -1.3f;

            v2f vert (const appdata v)
            {
                const float2 relative_uv = float2(
                   v.uv0.x * 2 - 1,
                   v.uv0.y * 2 - 1
                );

                float4 vertex_pos = v.vertex;
                vertex_pos.y += vertical_offset;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(vertex_pos, v.uv2.x));
                o.vertex_color = v.color;
                o.vertex_color.r *= _HighlightTest;
                o.uv = relative_uv;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float4 color = lerp(_IdleColor, _HighlightColor, i.vertex_color.r);
                float4 col = get_underline_color(color, i.uv, _Seed, i.vertex_color.r, _Waves);
                col *= i.vertex_color.a;
                return col;
            }
            ENDCG
        }
    }
}