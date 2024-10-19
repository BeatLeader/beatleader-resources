Shader "Unlit/UIBlurredBackground" {
    Properties {
        _MainTex ("Mask Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "PreviewType" = "Plane"
        }

        Pass {
            Cull Off
            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 mask_uv : TEXCOORD0;
                float4 grab_uv : TEXCOORD1;
                float2 local_pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _BlurredTex;
            float4 _Tint;
            float4 _ClipRect;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.mask_uv = v.uv0;
                o.grab_uv = ComputeGrabScreenPos(o.vertex);
                o.local_pos = v.vertex.xy;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float4 mask = tex2D(_MainTex, i.mask_uv) * _Tint;
                float4 col = tex2D(_BlurredTex, i.grab_uv.xy / i.grab_uv.w);
                col.rgb *= mask.rgb;
                col.a = mask.a;
                #ifdef UNITY_UI_CLIP_RECT
                col.a *= UnityGet2DClipping(i.local_pos, _ClipRect);
                #endif
                return col;
            }
            ENDCG
        }
    }
}