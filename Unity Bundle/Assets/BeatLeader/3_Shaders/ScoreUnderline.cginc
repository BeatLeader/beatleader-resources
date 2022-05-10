float get_shine_value(const float distance, const float noise, const float from, const float to_static, const float to_dynamic)
{
    const float_range range = create_range(from, to_static + to_dynamic * noise);
    return get_range_ratio_clamped(range, distance);
}

float get_noise_value(const float2 uv, const float world_y, const float_range fade_range, const float scale, const float speed, const float sharpness,
                      const float magnitude)
{
    float result = ClassicNoise(float3(uv.x * scale, world_y * scale, _Time.y * speed));
    result = get_range_ratio_clamped(fade_range, result);
    result = pow(result, sharpness) * magnitude;
    return result;
}

static const float_range x_fade_range = create_range(1.0, 0.96);

static const float static_glow = 0.01f;
static const float_range big_noise_fade_range = create_range(-1.0, 0.7);
static const float_range small_noise_fade_range = create_range(-0.6, 0.6);

float4 get_underline_color(const float4 halo_color, const float4 rim_color, const float2 uv, const float seed, const float highlight, const float noise)
{
    const float distance = uv.y + 0.5f;
    const float x_fade = get_range_ratio_clamped(x_fade_range, abs(uv.x));
    
    const float big_noise = get_noise_value(uv, seed, big_noise_fade_range, 4.0f, 0.5f, 6.0f, 0.3f);
    const float small_noise = get_noise_value(uv, seed, small_noise_fade_range, 12.0f, 0.3f, 16.0f, 0.6f);
    
    const float glow = static_glow + (big_noise + small_noise) * noise * highlight;

    float shine = get_shine_value(distance, glow, 0.3f + 0.9f * highlight, 0.024f, 0.3f);
    shine *= get_shine_value(distance, glow, -0.2f - 0.4f * highlight, -0.024f, -0.1f);
    shine = pow(shine, 5 - 4 * noise + log(1 / glow)) * x_fade;

    const float halo_value = pow(shine, 2);
    const float rim_value = pow(shine, 4);

    float4 col = halo_color * halo_value;
    col += rim_color * rim_value;
    return col;
}