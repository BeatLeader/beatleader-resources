Shader "Unlit/UIMiniProfileBackground"
{
    Properties
    {
        _Params ("Params", Vector) = (1, 2, 0.1, 0)
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
                float4 color : COLOR;
                float2 relative_uv : TEXCOORD0;
            };

            float4 _Params;

            static const float edge_margin = 0.01f;

            v2f vert (appdata v)
            {
                const float2 relative_uv = float2(
                   v.uv1.x * 2 - 1,
                   v.uv1.y * 2 - 1
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
                o.relative_uv = relative_uv;
                return o;
            }

            float get_fade_value(const float2 uv, float angle, const float from, const float to, const float thickness)
            {
                angle = clamp(angle, from, to);
                const float radius = 1 - thickness - edge_margin;
                const float2 p = float2(-sin(angle) * radius, cos(angle) * radius);
                const float d = length(p - uv);
                return 1 - clamp((d - (thickness - edge_margin * 2)) / edge_margin, 0.0f, 1.0f);
            }

            float4 frag (v2f i) : SV_Target
            {
                const float angle = -atan2(i.relative_uv.x, i.relative_uv.y);
                const float fade = get_fade_value(i.relative_uv, angle, _Params.x, _Params.y, _Params.z);
                float4 col = i.color;
                col.a *= fade;
                return col;
            }
            ENDCG
        }
    }
}
