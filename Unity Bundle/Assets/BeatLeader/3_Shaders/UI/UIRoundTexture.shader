Shader "BeatLeader/UIRoundTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Edge Radius", Float) = 0.1
        _EdgeSmoothSize ("Edge Smooth", Float) = 0.01
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        ZWrite Off
        ZTest Always
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            #include "Assets/BeatLeader/3_Shaders/Utils/utils.cginc"

            struct appdata {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 vertex : POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 local_pos : TEXCOORD2;
                
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float _Radius;
            float _EdgeSmoothSize;
            float4 _ClipRect;

            v2f vert(appdata v) {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.pos = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.uv = v.uv;
                o.uv1 = v.uv1;
                o.local_pos = v.vertex.xy;
                return o;
            }

            fixed4 frag(const v2f i): SV_Target {
                const float alpha = get_rounded_alpha(i.uv1, _Radius, _EdgeSmoothSize);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= alpha;
                #ifdef UNITY_UI_CLIP_RECT
                col.a *= UnityGet2DClipping(i.local_pos, _ClipRect);
                #endif
                return col;
            }
            ENDCG
        }
    }
}