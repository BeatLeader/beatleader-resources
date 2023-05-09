Shader "BeatLeader/AccDetailsRowBackground"
{
    Properties
    {
        _LeftColor ("LeftColor", Color) = (1, 1, 1, 1)
        _RightColor ("RightColor", Color) = (1, 1, 1, 1)
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
            #pragma multi_compile_instancing

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

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertex_color : COLOR;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            static const float_range y_remap_range = create_range(0.0, 0.08);
            static const float_range fancy_x_fade_range = create_range(0.5, 0.46);
            static const float_range y_fade_range = create_range(0.5, 0.1);
            static const float_range gradient_range = create_range(0.25, 0.75);

            float4 _LeftColor;
            float4 _RightColor;

            v2f vert (const appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.uv = float2(v.uv1.x, get_range_ratio(y_remap_range, v.uv1.y));
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                float fade = 1.0f;
                fade *= get_range_ratio_clamped(fancy_x_fade_range, abs(i.uv.x - 0.5f));
                fade *= get_range_ratio_clamped(y_fade_range, abs(i.uv.y - 0.5f));
                float4 col = lerp(_LeftColor, _RightColor, get_range_ratio_clamped(gradient_range, i.uv.x));
                col *= i.vertex_color.a * fade;
                return col;
            }
            ENDCG
        }
    }
}