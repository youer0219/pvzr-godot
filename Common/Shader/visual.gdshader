shader_type canvas_item;

// 摇摆强度，用来控制摇摆的幅度
uniform float strength = 2.0;
// 摇摆速度，决定摇摆的快慢
uniform float speed = 3.0;
// 闪烁颜色，源颜色，用于与纹理颜色混合
uniform vec4 blink_color:source_color;
// 闪烁强度，通过滑块调整，范围为 0 到 1
uniform float blink_intensity :hint_range(0.0, 1.0) = 0.0;
// 控制摇摆方向的布尔值：
// 如果为 true，则进行上下摇摆；
// 如果为 false，则进行左右摇摆。
uniform bool is_vertical = false;

// 顶点着色器部分
void vertex() {
    // 计算偏移量，这个偏移量基于时间和摇摆强度
    float offset = sin(TIME * speed) * strength ;

    // 如果是垂直摇摆（上下摇摆），则在 y 轴上进行偏移
    if (is_vertical) {
        VERTEX.y += offset * step(1., 1. - VERTEX.y) ;  // 垂直方向上的摇摆
    } else {
        // 否则是水平摇摆（左右摇摆），则在 x 轴上进行偏移
        VERTEX.x += offset * step(1., 1. - VERTEX.y) ;  // 水平方向上的摇摆
    }
}

// 片段着色器部分
void fragment() {
    // 获取当前纹理颜色
    vec4 color = texture(TEXTURE, UV);

    // 根据闪烁强度将纹理颜色与闪烁颜色进行混合
    color = mix(color, blink_color, blink_intensity * color.a);

    // 设置最终的片段颜色
    COLOR = color;
}
