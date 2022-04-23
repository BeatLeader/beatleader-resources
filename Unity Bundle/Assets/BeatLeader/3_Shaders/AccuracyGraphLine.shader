Shader "BeatLeader/AccuracyGraphLine"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
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

            float4 _Color;
            static const float_range range = create_range(1.0f, 0.5f);

            v2f vert (const appdata v)
            {
                const float2 uv = float2((v.uv0.x - 0.5f) * 2.0f, v.uv0.y);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.uv = uv;
                o.normalized_pos = v.uv1;
                o.vertex_color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                if (i.normalized_pos.x < 0.005f | i.normalized_pos.x > 0.995f | i.normalized_pos.y < 0.005f | i.normalized_pos.y > 0.995f) discard;

                const float fade = get_range_ratio_clamped(range, abs(i.uv.x));
                float4 col = _Color;
                col *= fade;
                return col;
            }
            ENDCG
        }
    }
}