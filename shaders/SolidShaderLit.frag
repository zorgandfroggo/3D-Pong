#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_SPOT_LIGHTS (MAX_LIGHTS / 3)
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
    float intensity;
    vec3 lightColor;
    float renderShadow;
    vec3 attenuation;
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
    float renderShadow;
};

layout(binding = 2) uniform LightsUBO
{
    PointLight lights[MAX_LIGHTS / 3];
    DirectionalLight dirLights[MAX_LIGHTS / 3];
    Spotlight spotlights[MAX_LIGHTS / 3];
    int numPointLights;
    int numDirLights;
    int numSpotlights;
    int padding;
} lightsUBO;

layout(binding = 5) uniform sampler2D shadowMap[MAX_DIR_LIGHTS];

layout(binding = 6) uniform samplerCube cubeMap[MAX_POINT_LIGHTS];

layout(binding = 7) uniform sampler2D spotShadowMap[MAX_SPOT_LIGHTS];

layout(location = 0) out vec4 outColor;
layout(location = 2) in vec3 Normal;
layout(location = 3) in vec3 FragPos;
layout(location = 5) in vec4 FragDirLightSpace[MAX_DIR_LIGHTS];
layout(location = 11) in vec4 FragSpotlightSpace[MAX_SPOT_LIGHTS];

vec3 sampleArray[20] =
{
    vec3(1, 1, 1), vec3(1, -1, 1), vec3(1, 1, -1), vec3(-1, 1, 1),
    vec3(-1, -1, 1), vec3(1, -1, -1), vec3(-1, -1, -1), vec3(-1, 1, -1),
    vec3(1, 1, 0), vec3(1, -1, 0), vec3(-1, -1, 0), vec3(-1, 1, 0),
    vec3(0, 1, 1), vec3(0, 1, -1), vec3(0, -1, 1), vec3(0, -1, -1),
    vec3(1, 0, 1), vec3(-1, 0, 1), vec3(1, 0, -1), vec3(-1, 0, -1)
};

float ShadowCalculations(vec4 fragPosLightSpace, vec3 normal, vec3 lightDir, int index)
{
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords.xy = projCoords.xy * 0.5 + 0.5;

    if (projCoords.x > 1.0 || projCoords.x < 0.0 || projCoords.y > 1.0 || projCoords.y < 0.0
    || projCoords.z > 1.0 || projCoords.z < 0.0)
    {
        return 0.0;
    }

    float closestDepth = texture(shadowMap[index], projCoords.xy).r;
    float currentDepth = projCoords.z;

    float bias = 0.001;

    // PCF
    float shadow = 0.0;
    vec2 texelSize = 1.0 / textureSize(shadowMap[index], 0);
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            float pcfDepth = texture(shadowMap[index], projCoords.xy + vec2(x, y) * texelSize).r;
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;
        }
    }

    shadow /= 9.0;
    return shadow;
}

float ShadowCalculationSpot(vec4 fragPos, int index)
{
    vec3 projCoords = fragPos.xyz / fragPos.w;
    projCoords.xy = projCoords.xy * 0.5 + 0.5;

    if (projCoords.x > 1.0 || projCoords.x < 0.0 || projCoords.y > 1.0 || projCoords.y < 0.0
    || projCoords.z > 1.0 || projCoords.z < 0.0)
    {
        return 0.0;
    }

    float closestDepth = texture(spotShadowMap[index], projCoords.xy).r;
    float currentDepth = projCoords.z;

    float bias = 0.001;

    // PCF
    float shadow = 0.0;
    vec2 texelSize = 1.0 / textureSize(spotShadowMap[index], 0);
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            float pcfDepth = texture(spotShadowMap[index], projCoords.xy + vec2(x, y) * texelSize).r;
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;
        }
    }

    shadow /= 9.0;
    return shadow;
}

float ShadowCalculationPoint(vec3 fragPos, vec3 lightPos, int index)
{
    float farPlane = 100;
    vec3 fragToLight = fragPos - lightPos;

    float currentDepth = length(fragToLight);

    // PCF
    float bias = 0.15;
    float diskRadius = 0.05;
    float shadow = 0;
    int samples = 20;

    for (int i = 0; i < samples; i++)
    {
        float closestDepth = texture(cubeMap[index], fragToLight + sampleArray[i] * diskRadius).r;
        closestDepth *= farPlane;
        if (currentDepth - bias > closestDepth)
        {
            shadow += 1;
        }
    }

    shadow /= float(samples);
    return shadow;
}

void main()
{
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(ubo.camPos.xyz - FragPos);
    vec3 result = vec3(0);
    vec3 ambient = ubo.ambient.xyz * ubo.baseColor.xyz;

    for (int i = 0; i < lightsUBO.numPointLights; i++)
    {
        float dist = length(lightsUBO.lights[i].lightPos - FragPos);
        float attenuation = 1.0 / (lightsUBO.lights[i].attenuation.x + lightsUBO.lights[i].attenuation.y * dist
        + lightsUBO.lights[i].attenuation.z * (dist * dist));

        vec3 lightDir = normalize(lightsUBO.lights[i].lightPos - FragPos);
        vec3 halfwayDir = normalize(viewDir + lightDir);
        float diff = max(dot(norm, lightDir), 0);
        vec3 diffuse = (diff * ubo.baseColor.xyz) * lightsUBO.lights[i].lightColor;
        diffuse *= attenuation;

        float spec = pow(max(dot(norm, halfwayDir), 0.0), ubo.shininess);
        vec3 specularVal = (spec * ubo.specular.xyz) * lightsUBO.lights[i].lightColor;
        specularVal *= attenuation;

        float shadow = 0;

        if (lightsUBO.lights[i].renderShadow > 0)
        {
            shadow = ShadowCalculationPoint(FragPos, lightsUBO.lights[i].lightPos, i);
        }

        result += (1 - shadow) * (diffuse + specularVal) * lightsUBO.lights[i].intensity;
    }

    for (int i = 0; i < lightsUBO.numDirLights; i++)
    {
        vec3 lightDir = normalize(-lightsUBO.dirLights[i].lightDir);
        vec3 halfwayDir = normalize(lightDir + viewDir);
        float diff = max(dot(norm, lightDir), 0);
        vec3 diffuse = (diff * ubo.baseColor.xyz) * lightsUBO.dirLights[i].lightColor;

        float spec = pow(max(dot(norm, halfwayDir), 0.0), ubo.shininess);
        vec3 specularVal = (spec * ubo.specular.xyz) * lightsUBO.dirLights[i].lightColor;

        float shadow = ShadowCalculations(FragDirLightSpace[i], norm, lightDir, i);

        result += (1 - shadow) * (diffuse + specularVal) * lightsUBO.dirLights[i].lightIntensity;
    }

    for (int i = 0; i < lightsUBO.numSpotlights; i++)
    {
        vec3 lightDir = normalize(lightsUBO.spotlights[i].lightPos - FragPos);
        vec3 halfwayDir = normalize(lightDir + viewDir);

        float theta = dot(lightDir, normalize(-lightsUBO.spotlights[i].lightDir));

        float epsilon = lightsUBO.spotlights[i].cutoff - lightsUBO.spotlights[i].outerCutoff;
        float intensity = clamp((theta - lightsUBO.spotlights[i].outerCutoff) / epsilon, 0.0, 1.0);

        float dist = length(lightsUBO.spotlights[i].lightPos - FragPos);
        float attenuation = 1.0 / (lightsUBO.spotlights[i].attenuation.x + lightsUBO.spotlights[i].attenuation.y * dist
        + lightsUBO.spotlights[i].attenuation.z * (dist * dist));

        float diff = max(dot(norm, lightDir), 0);
        vec3 diffuse = (diff * ubo.baseColor.xyz) * lightsUBO.spotlights[i].lightColor;
        diffuse *= attenuation;
        diffuse *= intensity;

        float spec = pow(max(dot(norm, halfwayDir), 0.0), ubo.shininess);
        vec3 specularVal = (spec * ubo.specular.xyz) * lightsUBO.spotlights[i].lightColor;
        specularVal *= attenuation;
        specularVal *= intensity;

        float shadow = 0;

        if (lightsUBO.spotlights[i].renderShadow > 0)
        {
            shadow = ShadowCalculationSpot(FragSpotlightSpace[i], i);
        }

        result += (1 - shadow) * (diffuse + specularVal) * lightsUBO.spotlights[i].intensity;
    }

    result += ambient;
    result = result / (result + vec3(1));
    outColor = vec4(result, 1);
}