Shader "BeatLeader/SaberHandle"
{
    Properties
    {
        _CoreColor ("Core Color", Color) = (1, 1, 1, 1)
        _HandleColor ("Handle Color", Color) = (0, 0, 0, 1)
        _HandleSize ("Handle Size", Range(0, 1)) = 0.8
        _CoreIntensity ("Core Intensity", Range(0, 1)) = 0.8
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _CoreColor;
            float4 _HandleColor;
            float _HandleSize;
            float _CoreIntensity;

            v2f vert(const appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i) : SV_Target {
                const float handle_offset = (1 - _HandleSize) / 2;
                const float handle_start = handle_offset;
                const float handle_end = 1 - handle_offset;
                
                fixed4 col = _CoreColor * _CoreIntensity;
                const float y = i.uv.y;
                if (y > handle_start && y < handle_end) {
                    col = _HandleColor;
                }
                
                return col;
            }
            ENDCG
        }
    }
}