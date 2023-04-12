Shader "BeatLeader/UISkillTriangle"
{
    Properties
    {
        _Normalized("NormalizedValues", Vector) = (1, 1, 1, 1)
        _OuterBorderColor("OuterBorderColor", Color) = (1, 1, 1, 1)
        _InnerBorderColor("InnerBorderColor", Color) = (1, 1, 1, 1)
        _TopLeftColor("TopLeftColor", Color) = (1, 1, 1, 1)
        _TopRightColor("TopRightColor", Color) = (1, 1, 1, 1)
        _BottomColor("BottomColor", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off

        Pass //ColorPass
        {
            BlendOp Add
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UISkillTriangle.cginc"

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

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
                float2 cartesian_coords : TEXCOORD0;
            };

            float3 _Normalized;
            float4 _OuterBorderColor;
            float4 _InnerBorderColor;
            float4 _TopLeftColor;
            float4 _TopRightColor;
            float4 _BottomColor;

            v2f vert (const appdata v)
            {
                const float2 cartesian_coords = float2(
                    (v.uv0.x - 0.5f) * 2,
                    (v.uv0.y - 0.5f) * 2 - 0.2
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.cartesian_coords = cartesian_coords;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const triangle_data inner_triangle = create_triangle_data(
                    outer_triangle.a_position * _Normalized.x,
                    outer_triangle.b_position * _Normalized.y,
                    outer_triangle.c_position * _Normalized.z
                );
                
                const point_check_data outer_check = check_point(outer_triangle, i.cartesian_coords);
                const point_check_data inner_check = check_point(inner_triangle, i.cartesian_coords);

                float4 in_col = float4(0, 0, 0, 0);
                in_col += _TopLeftColor * outer_check.a_proximity;
                in_col += _TopRightColor * outer_check.b_proximity;
                in_col += _BottomColor * outer_check.c_proximity;

                const float outer_border = get_triangle_border_dashed(outer_triangle, i.cartesian_coords, 0.14f, 0.02, 0.04);
                const float inner_border = get_triangle_border(inner_triangle, i.cartesian_coords, 0.01, 0.02);
                
                float4 col = in_col * inner_check.is_inside;
                col = lerp(col, _InnerBorderColor, inner_border);
                col = lerp(col, _OuterBorderColor, outer_border);
                return col;
            }
            ENDCG
        }
    }
}