Shader "TextureClearer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "White" {}
        _Area ("Area", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Area;

            v2f vert(const appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float map01(float val, float outMin, float outMax) {
                return val * (outMax - outMin) / 1 + outMin;
            }

            fixed4 frag(const v2f i) : SV_Target {
                float x = map01(i.uv.x, _Area.x, _Area.z);
                float y = map01(i.uv.y, _Area.y, _Area.w);
                return tex2D(_MainTex, fixed2(x, y));
            }
            ENDCG
        }
    }
}