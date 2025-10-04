Shader "BeatLeader/SaberBlade"
{
    Properties
    {
        _CoreColor ("Core Color", Color) = (1, 1, 1, 1)
        _CoreIntensity ("Core Intensity", Range (0, 1)) = 0.8
        _VoronoiIntensity ("Voronoi Intensity", Range(0, 1)) = 0.5
        _VoronoiScale ("Voronoi Scale", Range(1, 100)) = 10.0
        _VoronoiSpeed ("Voronoi Speed", Range(0, 10)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _CoreColor;
            float _CoreIntensity;
            float _VoronoiIntensity;
            float _VoronoiScale;
            float _VoronoiSpeed;

            v2f vert(const appdata v) {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target {
                const float2 uv_voronoi = frac(i.uv * _VoronoiScale + _Time.y * _VoronoiSpeed);
                const float2 cell = floor(uv_voronoi);
                const float2 dist = cell + 0.5 - uv_voronoi;
                const float voronoi = 1.0 - smoothstep(0.0, 0.1, min(dot(dist, dist), 1.0));

                const fixed4 col = _CoreColor * (_CoreIntensity + voronoi * _VoronoiIntensity);
                return col;
            }
            ENDCG
        }
    }
}