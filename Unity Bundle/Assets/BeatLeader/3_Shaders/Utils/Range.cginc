struct float_range
{
    float from;
    float amplitude;
};

static float_range create_range(const float from, const float to)
{
    float_range r;
    r.from = from;
    r.amplitude = to - from;
    return r;
}

//GET RATIO ================================================================
static float get_range_ratio(const float_range range, const float value)
{
    return (value - range.from) / range.amplitude;
}

static float get_range_ratio_clamped(const float_range range, const float value)
{
    return clamp((value - range.from) / range.amplitude, 0.0f, 1.0f);
}

//SLIDE ================================================================
static float slide_range(const float_range range, const float t)
{
    return range.from + range.amplitude * t;
}

static float slide_range_clamped(const float_range range, float t)
{
    t = clamp(t, 0.0f, 1.0f);
    return range.from + range.amplitude * t;
}

//MAP ================================================================
static float map_ranges(const float_range from, const float_range to, const float value)
{
    return slide_range(to, get_range_ratio(from, value));
}

static float map_ranges_clamped(const float_range from, const float_range to, const float value)
{
    return slide_range(to, get_range_ratio_clamped(from, value));
}