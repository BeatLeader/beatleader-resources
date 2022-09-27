Shader "BeatLeader/ClanTagBackground"
{
    Properties
    {
        _PowerX ("PowerX", Float) = 6
        _PowerY ("PowerY", Float) = 3
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
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"

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
            
            float _PowerX;
            float _PowerY;

            v2f vert (const appdata v)
            {
                const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
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

            float4 frag (const v2f i) : SV_Target
            {
                const float distance = get_super_ellipse_distance_to_circle(i.uv);
                const float alpha = get_range_ratio_clamped(alpha_range, distance);
                
                float4 col = i.vertex_color;
                col.a *= alpha * i.vertex_color.a;
                return col;
            }
            ENDCG
        }
    }
}