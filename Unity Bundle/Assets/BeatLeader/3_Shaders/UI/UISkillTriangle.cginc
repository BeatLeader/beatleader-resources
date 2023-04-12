//<- TRIANGLE DATA --------------------------------------

#include "Assets/BeatLeader/3_Shaders/Utils/Range.cginc"

struct triangle_data
{
    float2 a_position;
    float2 a_direction;
    float2 a_normal;
    float a_height;

    float2 b_position;
    float2 b_direction;
    float2 b_normal;
    float b_height;

    float2 c_position;
    float2 c_direction;
    float2 c_normal;
    float c_height;
};

triangle_data create_triangle_data(float2 a, float2 b, float2 c)
{
    triangle_data t;

    const float2 ab = b - a;
    const float2 bc = c - b;
    const float2 ca = a - c;

    t.a_position = a;
    t.b_position = b;
    t.c_position = c;

    t.a_direction = normalize(ab);
    t.b_direction = normalize(bc);
    t.c_direction = normalize(ca);

    t.a_normal = float2(-t.a_direction.y, t.a_direction.x);
    t.b_normal = float2(-t.b_direction.y, t.b_direction.x);
    t.c_normal = float2(-t.c_direction.y, t.c_direction.x);

    t.a_height = abs(dot(ab, t.b_normal));
    t.b_height = abs(dot(bc, t.c_normal));
    t.c_height = abs(dot(ca, t.a_normal));

    return t;
}

//<- POINT CHECK DATA --------------------------------------

struct point_check_data
{
    float a_distance;
    float b_distance;
    float c_distance;

    float ab_distance;
    float bc_distance;
    float ca_distance;

    float a_proximity;
    float b_proximity;
    float c_proximity;

    bool is_inside;
};

point_check_data check_point(const triangle_data t, float2 p)
{
    point_check_data r;

    const float a_dot = dot(p - t.a_position, t.b_normal);
    const float b_dot = dot(p - t.b_position, t.c_normal);
    const float c_dot = dot(p - t.c_position, t.a_normal);

    r.a_distance = length(p - t.a_position);
    r.b_distance = length(p - t.b_position);
    r.c_distance = length(p - t.c_position);

    r.bc_distance = a_dot - t.a_height;
    r.ca_distance = b_dot - t.b_height;
    r.ab_distance = c_dot - t.c_height;

    r.a_proximity = 1 - a_dot / t.a_height;
    r.b_proximity = 1 - b_dot / t.b_height;
    r.c_proximity = 1 - c_dot / t.c_height;

    r.a_proximity = pow(r.a_proximity, 3);
    r.b_proximity = pow(r.b_proximity, 3);
    r.c_proximity = pow(r.c_proximity, 3);

    r.is_inside = (r.bc_distance < 0) && (r.ca_distance < 0) && (r.ab_distance < 0);

    return r;
}

//<- OUTER TRIANGLE ----------------------------

static const float2 top_left_direction = float2(-0.86602540378444, 0.5f);
static const float2 top_right_direction = float2(0.86602540378444, 0.5f);
static const float2 bottom_direction = float2(0.0f, -1.0f);
static const float radius = 0.8f;

static const triangle_data outer_triangle = create_triangle_data(
    top_left_direction * radius,
    top_right_direction * radius,
    bottom_direction * radius
);

//<- BORDER ----------------------------

static const float_range margin_range = create_range(0.0, 0.4);

float get_line_value(float2 a, float2 b, float2 p, const float thickness)
{
    const float2 tangent = normalize(b - a);
    const float2 normal = float2(-tangent.y, tangent.x);

    const float is_inside = dot(a - p, b - p) < 0.0f;
    const float normal_value = (thickness - abs(dot(b - p, normal))) / thickness;

    return get_range_ratio_clamped(margin_range, normal_value) * is_inside;
}

float get_dashed_line_value(float2 a, float2 b, float2 p, const float dash_step, const float thickness)
{
    const float2 tangent = normalize(b - a);
    const float2 normal = float2(-tangent.y, tangent.x);

    const float is_inside = dot(a - p, b - p) < 0.0f;

    const float tangent_value = abs(0.5f - (dot(b - p, tangent) % dash_step) / dash_step) * 2;
    const float normal_value = (thickness - abs(dot(b - p, normal))) / thickness;

    return get_range_ratio_clamped(margin_range, tangent_value * normal_value) * is_inside;
}

float get_point_value(const float2 a, const float2 p, const float point_radius)
{
    const float value = 1 - length(a - p) / (point_radius);
    return get_range_ratio_clamped(margin_range, value) ;
}

float get_triangle_border_dashed(triangle_data t, const float2 p, const float dash_step, const float thickness, const float point_radius)
{
    float value = 0.0f;
    value += get_dashed_line_value(t.a_position, t.b_position, p, dash_step, thickness);
    value += get_dashed_line_value(t.b_position, t.c_position, p, dash_step, thickness);
    value += get_dashed_line_value(t.c_position, t.a_position, p, dash_step, thickness);
    value += get_point_value(t.a_position, p, point_radius);
    value += get_point_value(t.b_position, p, point_radius);
    value += get_point_value(t.c_position, p, point_radius);
    return clamp(value, 0, 1);
}

float get_triangle_border(triangle_data t, const float2 p, const float thickness, const float point_radius)
{
    float value = 0.0f;
    value += get_line_value(t.a_position, t.b_position, p, thickness);
    value += get_line_value(t.b_position, t.c_position, p, thickness);
    value += get_line_value(t.c_position, t.a_position, p, thickness);
    value += get_point_value(t.a_position, p, point_radius);
    value += get_point_value(t.b_position, p, point_radius);
    value += get_point_value(t.c_position, p, point_radius);
    return clamp(value, 0, 1);
}
