Shader "BeatLeader/UIGrid"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _BgColor("BgColor", Color) = (0, 0, 0, 0)
        _LineThickness("LineThickness", Float) = 0.01
        _CellSize("CellSize", Float) = 0.5
        _Width("Width", Float) = 1
        _Height("Height", Float) = 1
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _Color;
            float4 _BgColor;
            float _LineThickness;
            float _CellSize;
            float _Width;
            float _Height;

            v2f vert(appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            bool should_draw_pixel(float p, float size)
            {
                float j = _CellSize + _LineThickness;
                float dif = ((size % j) - _LineThickness) / 2; 
                return p > size - dif || (p - dif) % j < _LineThickness;
            }

            float4 frag(v2f i) : SV_Target
            {
                bool vertical_pixel_value = should_draw_pixel(
                    map(i.uv.y, 0, 1, 0, _Height), _Height);
                bool horizontal_pixel_value = should_draw_pixel(
                    map(i.uv.x, 0, 1, 0, _Width), _Width);
                
                return vertical_pixel_value || horizontal_pixel_value ? _Color : _BgColor;
            }
            ENDCG
        }
    }
}
