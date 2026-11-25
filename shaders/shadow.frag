#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_POINT_LIGHTS (MAX_LIGHTS / 3)

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

struct PointLight
{
    vec3 lightPos;
    vec3 lightColor;
    vec3 attenuation;
    float lightIntensity;
};

struct DirectionalLight
{
    vec3 lightDir;
    vec3 lightColor;
    float lightIntensity;
};

struct Spotlight
{
    vec3 lightDir;
    vec3 lightPos;
    vec3 lightColor;
    vec3 attenuation;
    float cutoff;
    float outerCutoff;
    float intensity;
};

layout(binding = 2) uniform LightsUBO
{
    PointLight lights[MAX_LIGHTS / 3];
    DirectionalLight dirLights[MAX_LIGHTS / 3];
    Spotlight spotlights[MAX_LIGHTS / 3];
    int numPointLights;
    int numDirLights;
    int numSpotlights;
} lightsUBO;

layout (push_constant) uniform PushConstants
{
    mat4 modelMatrix;
    int dirIndex;
    int pointIndex;
    int isPointLight;
} pc;

layout(location = 0) in vec4 FragPos;

void main()
{
    float farPlane = 100;
    float lightDistance = length(FragPos.xyz - lightsUBO.lights[pc.pointIndex].lightPos);
    lightDistance = lightDistance / farPlane;
    gl_FragDepth = lightDistance;
}