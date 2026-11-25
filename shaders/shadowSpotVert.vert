#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_POINT_LIGHTS (MAX_LIGHTS / 3)
#define MAX_SPOT_LIGHTS (MAX_LIGHTS / 3)

layout (push_constant) uniform PushConstants
{
    mat4 modelMatrix;
    int dirIndex;
    int pointIndex;
    int spotIndex;
    int lightType;
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

layout(location = 0) in vec3 inPosition;

void main()
{
    gl_Position = lightUBO.spotlightMatrices[pc.spotIndex] * pc.modelMatrix * vec4(inPosition, 1);
}