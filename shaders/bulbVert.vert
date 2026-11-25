#version 450

layout(push_constant) uniform PC
{
    mat4 view;
    mat4 proj;
    vec3 position;
} pc;

const vec2 vertices[4] =
{
    vec2(-1, -1),
    vec2(1, -1),
    vec2(1, 1),
    vec2(-1, 1)
};

const int indices[6] =
{
    0, 1, 2, 2, 3, 0
};

layout(location = 0) out vec2 uv;

void main()
{
    int index = indices[gl_VertexIndex];
    vec2 position = vertices[index];

    vec3 objPos = pc.position;
    vec4 clipSpace = pc.proj * pc.view * vec4(objPos, 1);
    vec2 ndcCenter = clipSpace.xy / clipSpace.w;

    if (clipSpace.w <= 0)
    {
        gl_Position = vec4(1.1, 1.1, 1.1, 1);
        return;
    }
    gl_Position = vec4(ndcCenter + position * vec2(0.04, 0.08), clipSpace.z / clipSpace.w, 1);

    uv = position * .5 + .5;
}