Shader "BeatLeader/UIScoreUnderline"
{
    Properties
    {
        _RimColor("RimColor", Color) = (1, 1, 1, 1)
        _HaloColor("HaloColor", Color) = (1, 1, 1, 1)
        _WavesAmplitude ("WavesAmplitude", Range(0, 1)) = 1
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
            #pragma multi_compile_instancing

            #include "Assets/BeatLeader/3_Shaders/Utils/KeijiroNoiseCommon3D.cginc"
            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"
            #include "ScoreUnderline.cginc"

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
            
            float4 _RimColor;
            float4 _HaloColor;
            float _WavesAmplitude;
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

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(vertex_pos, v.uv2.x));
                o.vertex_color = v.color;
                o.vertex_color.r *= _HighlightTest;
                o.uv = relative_uv;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float highlight = i.vertex_color.r;
                const float rim_brightness = 0.04f + 0.96f * highlight;
                const float halo_brightness = 0.2f + 0.9f * highlight;
                
                const float4 rim_color = _RimColor * rim_brightness;
                const float4 halo_color = _HaloColor * halo_brightness;
                
                float4 col = get_underline_color(halo_color, rim_color, i.uv, _Seed, highlight, _WavesAmplitude);
                col *= i.vertex_color.a;
                return col;
            }
            ENDCG
        }
    }
}