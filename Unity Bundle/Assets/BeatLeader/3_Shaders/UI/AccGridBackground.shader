Shader "BeatLeader/AccGridBackground"
{
    Properties
    {
        _BackColor ("BackColor", Color) = (1, 1, 1, 1)
        _PowerX ("PowerX", Float) = 5
        _PowerY ("PowerY", Float) = 5
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            float4 _BackColor;
            float _PowerX;
            float _PowerY;
            
            v2f vert (const appdata v)
            {
                const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
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
                float4 col = _BackColor;
                col.a *= alpha;
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
                float4 color : COLOR;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float _FakeBloomAmount;
            float _PowerX;
            float _PowerY;
            
            v2f vert (const appdata v)
            {
                const float2 scaled_uv = (v.uv1 - float2(0.5f, 0.5f)) * 2.0f;
                
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
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

            static const float_range alpha_range = create_range(0.0f, 0.2f);
            static const float_range fade_range = create_range(0.1f, 1.0f);

            float4 frag (const v2f i) : SV_Target
            {
                const float distance = get_super_ellipse_distance_to_circle(i.uv);
                const float alpha = get_range_ratio_clamped(alpha_range, distance);
                float fade = 1 - get_range_ratio_clamped(fade_range, distance);
                fade = pow(fade, 2);
                
                float4 col = i.color * fade;
                col *= alpha;
                return apply_fake_bloom(col, _FakeBloomAmount);
            }
            ENDCG
        }
    }
}