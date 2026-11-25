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