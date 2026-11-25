#version 450

// Grid data
layout(push_constant) uniform Grid
{
    float gridSize;
    float gridCellSize;
    float minPixelsBetweenLines;

    vec4 thinColorLine;
    vec4 thickColorLine;

    vec4 origin;
    vec4 camPosition;
} grid;

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

layout(location = 0) out vec2 uv;
layout(location = 1) out vec2 cameraPos;

// Grid position
const vec3 pos[4] =
{
        vec3(-1, -1, 0),
        vec3(1, -1, 0),
        vec3(1, 1, 0),
        vec3(-1, 1, 0)
};

// Indices
const int indices[6] =
{
        0, 1, 2, 2, 3, 0
};

void main()
{
    int index = indices[gl_VertexIndex];
    vec3 position = pos[index] * grid.gridSize;
    position.x += grid.camPosition.x;
    position.y += grid.camPosition.y;
    position += grid.origin.xyz;
    cameraPos = grid.camPosition.xy;
    gl_Position = ubo.proj * ubo.view * vec4(position, 1.0);
    uv = position.xy;
}