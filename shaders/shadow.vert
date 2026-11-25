#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_POINT_LIGHTS (MAX_LIGHTS / 3)

layout (push_constant) uniform PushConstants
{
    mat4 modelMatrix;
    int dirIndex;
    int pointIndex;
    int spotindex;
    int lightType;
} pc;

layout(location = 0) in vec3 inPosition;

void main()
{
    gl_Position = pc.modelMatrix * vec4(inPosition, 1);
}