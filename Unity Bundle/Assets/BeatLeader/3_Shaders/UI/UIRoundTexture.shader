Shader "BeatLeader/UIRoundTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Edge Radius", Float) = 0.1
        _EdgeSmoothSize("Edge Smooth", Float) = 0.01
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _Radius;
            float _EdgeSmoothSize;

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(const v2f i): SV_Target {
                fixed4 col = fixed4(0, 0, 0, 0);

                const float2 adj_uv = abs(i.uv - float2(0.5, 0.5));
                const float radius_sub = 0.5 - _Radius;
                const float dist_x = max(adj_uv.x - radius_sub, 0.0);
                const float dist_y = max(adj_uv.y - radius_sub, 0.0);
                const float dist = length(float2(dist_x, dist_y));

                const float alpha = smoothstep(0.0, _EdgeSmoothSize, 1.0 - dist / _Radius);

                col = tex2D(_MainTex, i.uv);
                col.a *= alpha;

                return col;
            }
            ENDCG
        }
    }
}