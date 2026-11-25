#version 450

layout(location = 0) in vec3 inPos;
layout(location = 1) in vec3 inColor;
layout(location = 0) out vec3 outColor;

layout(binding = 0) uniform UniformBufferObject
{
    mat4 model;
    mat4 view;
    mat4 proj;
    vec4 baseColor;
    vec4 camPos;
    vec4 ambient;
    vec4 specular;
    float shininess;
} ubo;

void main() {
    outColor = inColor;
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(inPos, 1.0);
}
