#include "Assets/BeatLeader/3_Shaders/Utils/KeijiroNoiseCommon3D.cginc"

// <-- RAMP --------------------------------------------->

float apply_ramp(const float value, const float4 ramp)
{
    const float unclamped_ratio = (value - ramp.x) / (ramp.y - ramp.x);
    return pow(clamp(unclamped_ratio, 0, 1), ramp.w) * ramp.z;
}

// <-- SHINE --------------------------------------------->

float get_shine_value(
    const float distance,
    const float noise,
    const float from,
    const float to_static,
    const float to_dynamic)
{
    const float_range range = create_range(from, to_static + to_dynamic * noise);
    return get_range_ratio_clamped(range, distance);
}

// <-- NOISE --------------------------------------------->

float3 _NoiseOffset;

float get_noise_value(
    const float time,
    const float2 uv,
    const float_range fade_range,
    const float scale,
    const float speed,
    const float sharpness,
    const float magnitude)
{
    float result = ClassicNoise(float3(normalize(uv) * scale + _NoiseOffset, time * speed));
    result = get_range_ratio_clamped(fade_range, result);
    result = pow(result, sharpness) * magnitude;
    return result;
}

// <-- WAVES EFFECT --------------------------------------------->

static const float static_glow = 0.04f;
static const float_range big_noise_fade_range = create_range(-1.0, 0.6);
static const float_range small_noise_fade_range = create_range(-0.6, 0.6);

float _WavesAmplitude;
float4 _WavesConfig; // x: static_glow,  y: big_noise_amplitude,  z: small_noise_amplitude

float get_waves_value_with_speed(const float2 relative_uv, const float time, const float speed)
{
    const float big_noise = get_noise_value(
        time,
        relative_uv,
        big_noise_fade_range,
        2.0f,
        speed,
        4.0f,
        _WavesConfig.y
    );

    const float small_noise = get_noise_value(
        time,
        relative_uv,
        small_noise_fade_range,
        4.0f,
        speed * 0.6f,
        16.0f,
        _WavesConfig.z
    );

    const float glow = _WavesConfig.x + big_noise + small_noise;
    const float distance = length(relative_uv) - 1;

    float shine = get_shine_value(distance, glow, 0.5, 0.005, 0.1);
    shine *= get_shine_value(distance, glow, -0.3, -0.001, -0.02);
    return pow(shine, _WavesConfig.w + log(1 / glow));
}

float get_waves_value(const float2 relative_uv, const float time)
{
    return get_waves_value_with_speed(relative_uv, time, 0.5f);
}

// <-- DETAILS --------------------------------------------->

float4 _DetailsNoiseRamp;
float4 _DetailsInRamp;
float4 _DetailsOutRamp;
float4 _DetailsConfig0; // x: tube_radius,  y: tube_length,  z: skew
float4 _DetailsConfig1; // x: scroll_speed,  y: rot_speed
float _DetailsAmplitude;

static const float_range details_in_range = create_range(0.98, 1.0);
static const float_range details_out_range = create_range(1.5, 1.04);

float get_details_value(const float2 relative_uv, const float time)
{
    const float distance = length(relative_uv);

    float angle = atan2(relative_uv.y, relative_uv.x);
    angle += _DetailsConfig0.z * distance; //skew
    angle += time * _DetailsConfig1.y; //rot

    const float3 pos = float3(
        cos(angle) * _DetailsConfig0.x,
        sin(angle) * _DetailsConfig0.x,
        (-time * _DetailsConfig1.x + distance) * _DetailsConfig0.y
    );

    float result = apply_ramp(ClassicNoise(pos), _DetailsNoiseRamp);
    result *= apply_ramp(distance, _DetailsInRamp);
    result *= apply_ramp(distance, _DetailsOutRamp);
    return result;
}
