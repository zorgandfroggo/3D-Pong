#version 450

#include "GridMath.glsl"

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

//
layout(location = 0) in vec2 uv;
layout(location = 1) in vec2 cameraPos;
layout(location = 0) out vec4 outColor;

vec4 gridColor(vec2 uv, vec2 cameraPos)
{
    // Gets the change in uv accross screen pixels
    vec2 dudv = vec2(length(vec2(dFdx(uv.x), dFdy(uv.x))), length(vec2(dFdx(uv.y), dFdy(uv.y))));

    // Determines what level of detail to use
    float lodLevel = max(0.0, log10(length(dudv) * grid.minPixelsBetweenLines / grid.gridCellSize) + 1.0);

    // Fades smoothly into the next level of detail
    float lodFade = fract(lodLevel);

    // The levels of detail used by converting screen space grid size into logarithmic scale
    float lod0 = grid.gridCellSize * pow(10.0, floor(lodLevel));
    float lod1 = lod0 * 10;
    float lod2 = lod1 * 10;

    // Anti-ailasing offset to center and calculate line coverage
    dudv *= 4;
    uv += dudv * 0.5;

    // Determines how much to color a pixel based if its on a grid line or not
    float lod0a = max2(vec2(1.0) - abs(satv(mod(uv, lod0) / dudv) * 2.0 - vec2(1.0)));
    float lod1a = max2(vec2(1.0) - abs(satv(mod(uv, lod1) / dudv) * 2.0 - vec2(1.0)));
    float lod2a = max2(vec2(1.0) - abs(satv(mod(uv, lod2) / dudv) * 2.0 - vec2(1.0)));

    // Chooses between thick and thin colors depending on grid
    vec4 color;
    if (lod2a > 0.0)
    {
        color = grid.thickColorLine;
    }
    else if (lod1a > 0.0)
    {
        color = mix(grid.thickColorLine, grid.thinColorLine, lodFade);
    }
    else
    {
        color = grid.thinColorLine;
    }

    // Makes grid dissapear when camera is far enough away
    uv -= cameraPos;
    float opacityFalloff = (1.0 - satf(length(uv) / grid.gridSize));

    // Blends between LOD alpha levels and scales result of opacity falloff factor
    if (lod2a > 0.0)
    {
        color.a *= lod2a;
    }
    else if (lod1a > 0.0)
    {
        color.a *= lod1a;
    }
    else
    {
        color.a *= (lod0a * (1.0 - lodFade));
    }
    color.a *= opacityFalloff;

    return color;
}

void main()
{
    outColor = gridColor(uv, cameraPos);
}