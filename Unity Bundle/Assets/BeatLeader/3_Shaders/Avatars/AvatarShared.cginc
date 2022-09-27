// <-- DATA ---------------------------------------------

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

// <-- VERTEX SHADER ---------------------------------------------

float _Scale = 1.5f;
static const float _SpinnerScale = 0.5f;
static const float _SpinnerSpeed = 100.0f;
static const float2 offset = float2(0.5f, 0.5f);

v2f avatar_vertex_shader (const appdata v)
{
    float2 spinner_uv = (v.uv0 - offset) / _SpinnerScale;
    spinner_uv = rotate_uv(spinner_uv, -_Time * _SpinnerSpeed);
    spinner_uv *= _Scale;
    spinner_uv += offset;
                
    const float2 relative_uv = float2(
       (v.uv0.x * 2 - 1) * _Scale,
       (v.uv0.y * 2 - 1) * _Scale
    );

    const float2 avatar_uv = (relative_uv + 1) / 2;
                
    v2f o;
    o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
    o.color = v.color;
    o.avatar_uv = avatar_uv;
    o.spinner_uv = spinner_uv;
    o.relative_uv = relative_uv;
    return o;
}

// <-- FRAGMENT SHADER ---------------------------------------------

sampler2D _AvatarTexture;
float _FadeValue;
float4 _BackgroundColor;
sampler2D _Spinner;

static const float_range angle_fade_range = create_range(1.0, 0.96);

float4 avatar_fragment_shader (const v2f i) : SV_Target
{
    float fade = 1 - get_range_ratio_clamped(angle_fade_range, length(i.relative_uv));
    fade = 1 - fade * fade;

    const float4 spinner = tex2D(_Spinner, i.spinner_uv);
    const float4 avatar = tex2D(_AvatarTexture, i.avatar_uv);

    float4 col = lerp(spinner, avatar, _FadeValue);
    col = alpha_blend(col, _BackgroundColor);
    col.a *= fade * i.color.a;
    return col;
}