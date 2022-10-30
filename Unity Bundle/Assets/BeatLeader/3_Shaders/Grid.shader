Shader "BeatLeader/Grid"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _HorizontalCells("HorizontalCells", Float) = 6
        _VerticalCells("VerticalCells", Float) = 6
        _LineThickness("LineThickness", Float) = 0.01
        _AspectRatio("AspectRatio", Float) = 1
    }
    
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _Color;
            float _HorizontalCells;
            float _VerticalCells;
            float _LineThickness;
            float _AspectRatio;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float get_line_value(const float offset, const float cells_count, const float line_thickness)
            {
                return ((offset + line_thickness / 2) % (1 / cells_count)) < line_thickness;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float vertical_line_value = get_line_value(i.uv.x, _HorizontalCells, _LineThickness / _AspectRatio);
                const float horizontal_line_value = get_line_value(i.uv.y, _VerticalCells, _LineThickness);
                
                float4 col = _Color;
                col.a *= max(vertical_line_value, horizontal_line_value);
                return col;
            }
            ENDCG
        }
    }
}
