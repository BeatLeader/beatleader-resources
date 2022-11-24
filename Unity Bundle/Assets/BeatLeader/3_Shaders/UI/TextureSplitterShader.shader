Shader "BeatLeader/TextureSplitterShader"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (255, 255, 255, 255)
        _Zone("Zone", Vector) = (0, 0, 1, 1)
    }

    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        ColorMask RGB
        ZWrite OFF
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma warning disable

            #include "UnityCG.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _Zone;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float xmin = min(_Zone.x, _Zone.z);
                float xmax = max(_Zone.x, _Zone.z);

                float ymin = min(_Zone.y, _Zone.w);
                float ymax = max(_Zone.y, _Zone.w);

                float uvx = float(map(i.uv.x, 0, 1, xmin, xmax));
                float uvy = float(map(i.uv.y, 0, 1, ymin, ymax));

                fixed4 color = tex2D(_MainTex, float2(uvx, uvy));
                color *= _Color;

                return color;
            }
            ENDCG
        }
    }
}
