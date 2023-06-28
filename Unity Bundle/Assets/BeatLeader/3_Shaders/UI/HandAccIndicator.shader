Shader "BeatLeader/HandAccIndicator"
{
    Properties
    {
        _FillValue ("FillValue", Range(0, 1)) = 1
        _Thickness ("Thickness", Range(0, 1)) = 1
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
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
                float2 uv0 : TEXCOORD0;
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

            float _FillValue;
            float _Thickness;
            
            v2f vert (const appdata v)
            {
                const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.uv = scaled_uv;
                return o;
            }

            static const float_range length_fade_range = create_range( 0.0f, -0.02);

            float4 frag (const v2f i) : SV_Target
            {
                const float distance = abs(1 - length(i.uv) - _Thickness) - _Thickness;
                const float distance_fade = get_range_ratio_clamped(length_fade_range, distance);
                
                float4 col = i.vertex_color;
                col.xyz *= 0.1f;
                col.a = distance_fade;
                return col;
            }
            ENDCG
        }

        Pass
        {
            BlendOp Add
            Blend One One
            
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
                float2 uv0 : TEXCOORD0;
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

            float _FillValue;
            float _Thickness;
            
            v2f vert (const appdata v)
            {
                const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.vertex_color = v.color;
                o.uv = scaled_uv;
                return o;
            }

            static const float max_angle = UNITY_PI * 1.01f;
            static const float_range angle_fade_range = create_range( 0.0f, -0.03);
            static const float_range length_fade_range = create_range( 0.0f, -0.02);

            float4 frag (const v2f i) : SV_Target
            {
                const float angle = atan2(i.uv.y, abs(i.uv.x)) + UNITY_HALF_PI - max_angle * _FillValue;
                const float distance = abs(1 - length(i.uv) - _Thickness) - _Thickness;

                const float angle_fade = get_range_ratio_clamped(angle_fade_range, angle);
                const float distance_fade = get_range_ratio_clamped(length_fade_range, distance);
                
                return i.vertex_color * distance_fade * angle_fade;
            }
            ENDCG
        }
    }
}