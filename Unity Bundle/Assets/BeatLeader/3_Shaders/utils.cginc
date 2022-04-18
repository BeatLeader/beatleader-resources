float3 get_curved_position(const float3 local_pos, const float radius)
{
    return float3(
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
