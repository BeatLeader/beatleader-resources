Shader "Custom/Confetti"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "Queue"="Geometry-1"
        }

        ColorMask RGB
        Blend One OneMinusSrcColor
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv: TEXCOORD0;
                float4 vertex_color: COLOR;
                float3 normal: NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 vertex_color: COLOR;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            static const float waveAmplitude = 0.5;
            static const float waveFrequency = 2.0;
            static const float waveSpeed = 1.0;
            static const float groundFacingThreshold = 0.2;

            fixed4 _Color;

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                if (dot(v.normal, float3(0, -1, 0)) <= groundFacingThreshold) {
                    float wave = sin(v.vertex.x * waveFrequency + _Time.y * waveSpeed) * waveAmplitude;
                    v.vertex.y += wave;
                }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertex_color = v.vertex_color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return _Color * i.vertex_color.a;
            }
            ENDCG
        }
    }
}