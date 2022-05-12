float3 get_curved_position(const float3 local_pos, const float radius)
{
    return (radius < 1e-10f) ? local_pos : float3(
        sin(local_pos.x / radius) * radius,
        local_pos.y,
        cos(local_pos.x / radius) * radius - radius
    );
}

float2 rotate_uv(float2 uv, const float angle)
{
    const float c = cos(angle);
    const float s = sin(angle);
    return float2(
        c * uv.x + s * uv.y,
        -s * uv.x + c * uv.y
    );
}

float4 alpha_blend(float4 source, float4 destination)
{
    return source * source.a + destination * (1 - source.a);
}

float4 apply_fake_bloom(float4 source_color, const float fake_bloom_value)
{
    const float fake_bloom_brightness = pow(source_color.a, 2) * fake_bloom_value;

    return float4(
        source_color.r + fake_bloom_brightness,
        source_color.g + fake_bloom_brightness,
        source_color.b + fake_bloom_brightness,
        source_color.a
    );
}
