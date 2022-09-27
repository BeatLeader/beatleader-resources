static const float_range range = create_range(1.0f, 0.9f);
static const float_range mask_range = create_range(-0.02f, 0.0f);
static const float_range dot_fade_range = create_range(0.0f, 0.02f);

float get_dot_value(const float2 uv, const float dot_scale)
{
    return get_range_ratio_clamped(dot_fade_range, dot_scale - length(uv));
}

float get_mask_value(const float2 position, const float amplitude)
{
    const float a = amplitude - abs(atan2(position.y, position.x)) / UNITY_PI;
    return get_range_ratio_clamped(mask_range, a);
}

float get_boundary_distance_signed(const float x, const float y, const float side, const float radius)
{
    const float circle_offset = side - radius;
    const float xx = abs(x) - circle_offset;
    const float yy = abs(y) - circle_offset;
                
    const bool zone_c = xx > 0 && yy > 0;
    const bool zone_a = (!zone_c) && (xx <= yy);
    const bool zone_b = (!zone_c) && (xx > yy);

    float result = 0.0f;
    result += zone_a * yy;
    result += zone_b * xx;
    result += zone_c * sqrt(pow(xx, 2.0f) + pow(yy, 2.0f));
    return result - radius;
}

float get_fade_value(const float2 uv, const float scale, const float radius, const float thickness)
{
    const float distance = get_boundary_distance_signed(uv.x, uv.y, scale, radius);
    return get_range_ratio_clamped(range, abs(distance) / thickness);
}