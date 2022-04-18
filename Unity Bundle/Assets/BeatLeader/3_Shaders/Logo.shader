Shader "Ree/BLLogo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "White" {}
        _DotColor ("DotColor", Color) = (1, 1, 1, 1)
        _Glow ("Glow", Float) = 0
        _DotScale ("DotScale", Range(0, 1)) = 0
        _BlockScale ("BlockScale", Range(0, 1)) = 0
        _CornerRadius ("CornerRadius", Range(0, 1)) = 0
        _Thickness ("Thickness", Range(0, 1)) = 0
        _SpinnerRotation ("SpinnerRotation", Float) = 0
        _SpinnerAmplitude ("SpinnerAmplitude", Range(0, 1)) = 0
    }
    
    SubShader
    {
        Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"
            #include "Logo.cginc"

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
                float2 position : TEXCOORD1;
                float2 rotated : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _DotColor;
            float _DotScale;
            float _BlockScale;
            float _CornerRadius;
            float _Thickness;
            float _SpinnerRotation;
            float _SpinnerAmplitude;

            v2f vert (const appdata v)
            {
                const float2 position = float2(
                   v.uv0.x * 2 - 1,
                   v.uv0.y * 2 - 1
                );
                
                const float2 rotated = rotate_uv(position, _SpinnerRotation);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.avatar_uv = v.uv0;
                o.position = position;
                o.rotated = rotated;
                o.color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float mask = get_mask_value(i.rotated, _SpinnerAmplitude);
                const float block_value = mask * get_fade_value(i.rotated, _BlockScale, _CornerRadius, _Thickness);
                const float dot_value = get_dot_value(i.position, _DotScale);
                
                float4 block_color = tex2D(_MainTex, i.avatar_uv) * (block_value > 0);
                block_color.a = block_value;
                
                float4 dot_color = _DotColor * (dot_value > 0);
                dot_color.a = dot_value;

                float4 col = block_color + dot_color;
                col.a *= i.color.a;
                return col;
            }
            ENDCG
        }

        Pass
        {
            BlendOp Add
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "utils.cginc"
            #include "Range.cginc"
            #include "Logo.cginc"

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
                float2 position : TEXCOORD1;
                float2 rotated : TEXCOORD2;
            };

            float _Glow;
            float _BlockScale;
            float _CornerRadius;
            float _Thickness;
            float _SpinnerRotation;
            float _SpinnerAmplitude;

            v2f vert (const appdata v)
            {
                const float2 position = float2(
                   v.uv0.x * 2 - 1,
                   v.uv0.y * 2 - 1
                );
                
                const float2 rotated = rotate_uv(position, _SpinnerRotation);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.avatar_uv = v.uv0;
                o.position = position;
                o.rotated = rotated;
                o.color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float mask = get_mask_value(i.rotated, _SpinnerAmplitude);
                const float block_value = mask * get_fade_value(i.rotated, _BlockScale, _CornerRadius, _Thickness);
                return float4(0, 0, 0, _Glow * block_value * i.color.a);
            }
            ENDCG
        }
    }
}
