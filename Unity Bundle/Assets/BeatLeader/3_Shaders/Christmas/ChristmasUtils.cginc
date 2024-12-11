//<-- UTILITIES -----------------------------------------------------------------------

float3 apply_direction_light(const float3 albedo, const float3 normal, const float3 light_direction, const float3 light_color) {
    float intensity = -dot(normal, light_direction);
    intensity *= intensity > 0;
    return albedo * light_color * intensity;
}

float3 apply_static_light(const float3 albedo, const float3 light_color) {
    return albedo * light_color;
}

float3 apply_fake_lights(const float3 albedo, const float3 normal) {
    float3 col = apply_direction_light(albedo, normal, float3(0, -1, -1), float3(0.6f, 0.67f, 0.79f) * 0.3f);
    col += apply_direction_light(albedo, normal, float3(0, 0, 1), float3(0.016f, 0.016f, 0.22f));
    col += apply_static_light(albedo, float3(0.04f, 0.04f, 0.06f));
    return col;
}

//<-- LIGHTS -----------------------------------------------------------------------

static float3 bulb_color_a = float3(1.0f, 0.3f, 0.2f); // Warm pinkish-red
static float3 bulb_color_b = float3(0.3f, 0.5f, 1.0f); // Muted blue
static float3 bulb_color_c = float3(1.0f, 0.7f, 0.24f); // Golden 

float3 get_bulb_color(float3 intensities) {
    float3 result = float3(0, 0, 0);
    result += bulb_color_a * intensities.r;
    result += bulb_color_b * intensities.g;
    result += bulb_color_c * intensities.b;
    return result;
}

float3 christmas_lights_cycle_1(float time) {
    float red_intensity = abs(sin(time));
    float green_intensity = abs(sin(time + 1.0));
    float blue_intensity = abs(sin(time + 2.0));
    return float3(red_intensity, green_intensity, blue_intensity);
}

float3 christmas_lights_cycle_2(float time) {
    float red_intensity = smoothstep(-1.0, 1.0, sin(time));
    float green_intensity = smoothstep(-1.0, 1.0, sin(time + 2.0));
    float blue_intensity = smoothstep(-1.0, 1.0, sin(time + 4.0));
    return float3(red_intensity, green_intensity, blue_intensity);
}

float3 christmas_lights_cycle_3(float time) {
    float red_intensity = step(0.5, frac(time));
    float green_intensity = step(0.5, frac(time + 0.333));
    float blue_intensity = step(0.5, frac(time + 0.666));
    return float3(red_intensity, green_intensity, blue_intensity);
}

float3 christmas_lights_cycle() {
    float3 lights;
    float cycle_time = 5.0f; // Duration for each cycle in seconds
    float total_cycle_time = cycle_time * 3.0f; // Total time for all four cycles
    float time_in_cycle = fmod(_Time.y, total_cycle_time); // Looping time within the total cycle

    if (time_in_cycle < cycle_time) {
        lights = christmas_lights_cycle_1(time_in_cycle);
    } else if (time_in_cycle < 2.0f * cycle_time) {
        lights = christmas_lights_cycle_2(time_in_cycle - cycle_time);
    } else {
        lights = christmas_lights_cycle_3(time_in_cycle - 2.0f * cycle_time);
    }

    return lights;
}
