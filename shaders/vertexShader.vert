#version 450

#define MAX_LIGHTS 18
#define MAX_DIR_LIGHTS (MAX_LIGHTS / 3)
#define MAX_POINT_LIGHTS (MAX_LIGHTS / 3)
#define MAX_SPOT_LIGHTS (MAX_LIGHTS / 3)

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
layout(location = 2) in vec2 inTexCoord;
layout(location = 3) in vec3 aNormal;

layout(location = 1) out vec2 fragTextCoord;
layout(location = 2) out vec3 Normal;
layout(location = 3) out vec3 FragPos;
layout(location = 4) out vec4 outBaseColor;
layout(location = 5) out vec4 FragDirLightSpace[MAX_DIR_LIGHTS];
layout(location = 11) out vec4 FragSpotlightSpace[MAX_SPOT_LIGHTS];

void main()
{
	Normal = mat3(transpose(inverse(ubo.model))) * aNormal;
	FragPos = vec3(ubo.model * vec4(inPosition, 1));
	fragTextCoord = inTexCoord;
	outBaseColor = ubo.baseColor;

	for (int i = 0; i < lightUBO.numDirLights; i++)
	{
		FragDirLightSpace[i] = lightUBO.dirLightMatrices[i] * vec4(FragPos, 1);
	}

	for (int i = 0; i < lightUBO.numSpotlights; i++)
	{
		FragSpotlightSpace[i] = lightUBO.spotlightMatrices[i] * vec4(FragPos, 1);
	}

	gl_Position = ubo.proj * ubo.view * ubo.model * vec4(inPosition, 1.0);
}