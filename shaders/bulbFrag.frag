#version 450

layout(location = 0) out vec4 outColor;
layout(location = 0) in vec2 uv;

layout(binding = 1) uniform sampler2D texSampler;

void main()
{
    vec4 texColor = texture(texSampler, uv);
    if (texColor.a < 1)
    {
        discard;
    }
    outColor = texture(texSampler, uv);
}