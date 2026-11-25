#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_POINT_LIGHTS (MAX_LIGHTS / 3)
#define MAX_SPOT_LIGHTS (MAX_LIGHTS / 3)

layout(triangles) in;
layout(triangle_strip, max_vertices = 18) out;

layout (push_constant) uniform PushConstants
{
    mat4 modelMatrix;
    int dirIndex;
    int pointIndex;
    int isPointLight;
} pc;

layout(binding = 4) uniform LightMatrixUBO
{
    mat4 dirLightMatrices[MAX_DIR_LIGHTS];
    mat4 pointLightMatrices[MAX_POINT_LIGHTS * 6];
    mat4 spotlightMatrices[MAX_SPOT_LIGHTS];
    int numDirLights;
    int numPointLights;
    int numSpotlights;
} lightUBO;

layout(binding = 5) uniform sampler2D shadowMap[MAX_DIR_LIGHTS];
layout(binding = 6) uniform samplerCube cubeMap[MAX_POINT_LIGHTS];

layout(location = 0) out vec4 FragPos;

void main()
{
    for (int face = 0; face < 6; face++)
    {
        for (int i = 0; i < 3; i++)
        {
            gl_Layer = face;
            FragPos = gl_in[i].gl_Position;
            gl_Position = lightUBO.pointLightMatrices[pc.pointIndex * 6 + face] * FragPos;
            EmitVertex();
        }
        EndPrimitive();
    }
}