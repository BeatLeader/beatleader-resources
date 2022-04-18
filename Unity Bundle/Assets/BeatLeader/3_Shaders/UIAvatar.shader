Shader "Ree/UIAvatar"
{
    Properties
    {
        _AvatarTexture ("Texture", 2D) = "white" {}
        _FadeValue ("FadeValue", Range(0, 1)) = 1
        _BackgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
        _Spinner ("Spinner", 2D) = "white" {}
        _SpinnerScale ("SpinnerScale", float) = 1
        _SpinnerSpeed ("SpinnerSpeed", float) = 100
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 avatar_uv : TEXCOORD0;
                float2 spinner_uv : TEXCOORD1;
                float2 relative_uv : TEXCOORD2;
            };

            sampler2D _AvatarTexture;
            float _SpinnerScale;
            float _SpinnerSpeed;
            float _FadeValue;
            float4 _BackgroundColor;
            sampler2D _Spinner;

            v2f vert (const appdata v)
            {
                float2 spinner_uv = (v.uv0 - float2(0.5f, 0.5f)) / _SpinnerScale;
                spinner_uv = rotate_uv(spinner_uv, -_Time * _SpinnerSpeed);
                spinner_uv += float2(0.5f, 0.5f);
                
                const float2 relative_uv = float2(
                   v.uv0.x * 2 - 1,
                   v.uv0.y * 2 - 1
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.color = v.color;
                o.avatar_uv = v.uv0;
                o.spinner_uv = spinner_uv;
                o.relative_uv = relative_uv;
                return o;
            }

            static const float_range fade_range = create_range(1.0, 0.96);

            float4 frag (const v2f i) : SV_Target
            {
                float fade = 1 - get_range_ratio_clamped(fade_range, length(i.relative_uv));
                fade = 1 - fade * fade;

                const float4 spinner = tex2D(_Spinner, i.spinner_uv);
                const float4 avatar = tex2D(_AvatarTexture, i.avatar_uv);

                float4 col = lerp(spinner, avatar, _FadeValue);
                col = alpha_blend(col, _BackgroundColor);
                col.a *= fade * i.color.a;
                return col;
            }
            ENDCG
        }
    }
}