Shader "BeatLeader/VotingButton"
{
    Properties
    {
        _SpinnerTex ("Spinner Texture", 2D) = "white" {}
        _GradientTex ("Gradient Texture", 2D) = "white" {}
        _Atlas ("Atlas", 2D) = "white" {}
        
        _SpinnerValue ("SpinnerValue", Range(0, 1)) = 1
        _GradientValue ("GradientValue", Range(0, 1)) = 1
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        [IntRange] _State ("State", Range(0, 2)) = 0

        _SpinnerScale ("SpinnerScale", float) = 1
        _SpinnerSpeed ("SpinnerSpeed", float) = 100
        _GradientScale ("GradientScale", float) = 1
        _GradientSpeed ("GradientSpeed", float) = 100
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off
        BlendOp Add
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "utils.cginc"
            #include "UnityCG.cginc"

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
                float2 atlas_uv : TEXCOORD0;
                float2 spinner_uv : TEXCOORD1;
                float2 gradient_uv : TEXCOORD2;
            };

            sampler2D _SpinnerTex;
            sampler2D _GradientTex;
            sampler2D _Atlas;
            
            float _SpinnerValue;
            float _GradientValue;
            float4 _Tint;
            float _State;
            
            float _SpinnerScale;
            float _SpinnerSpeed;
            float _GradientScale;
            float _GradientSpeed;
            float _FakeBloomAmount;
            
            static const float2 offset = float2(0.5f, 0.5f);
            static const float total_states = 3.0f;
            static const float x_offset_per_state = 1.0f / total_states;

            v2f vert (const appdata v)
            {
                float2 spinner_uv = (v.uv0 - offset) / _SpinnerScale;
                spinner_uv = rotate_uv(spinner_uv, -_Time * _SpinnerSpeed);
                spinner_uv += offset;
                
                float2 gradient_uv = (v.uv0 - offset) / _GradientScale;
                gradient_uv = rotate_uv(gradient_uv, -_Time * _GradientSpeed);
                gradient_uv += offset;

                const float2 atlas_uv = float2(
                    v.uv0.x / total_states + x_offset_per_state * _State,
                    v.uv0.y
                );
                
                v2f o;
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.atlas_uv = atlas_uv;
                o.spinner_uv = spinner_uv;
                o.gradient_uv = gradient_uv;
                o.color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float4 spinner = tex2D(_SpinnerTex, i.spinner_uv);
                const float4 gradient = tex2D(_GradientTex, i.gradient_uv);
                const float3 tint = lerp(_Tint, gradient, _GradientValue);
                
                const float hovered = i.color.r * (abs(_State - 1) < 1e-10);
                const float glow = _Tint.a;
                
                float4 col = tex2D(_Atlas, i.atlas_uv);
                col = lerp(col, spinner, _SpinnerValue);
                col *= 1 - hovered * 0.4f;
                col.xyz *= tint * col.a;
                col.a *= glow;
                col *= i.color.a;
                return apply_fake_bloom(col, _FakeBloomAmount);
            }
            ENDCG
        }
    }
}