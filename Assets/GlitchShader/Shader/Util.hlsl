#pragma once

inline fixed maxElement(fixed3 v)
{
  return max(max(v[0], v[1]), v[2]);
}

inline float2 computeGlitch(
    float yPos,
    float period,
    float minY,
    float maxY,
    float2 normPrjViewDir,
    float sharpness
) {
    float glitchYPos = (1 - frac(_Time.y / period)) * (maxY - minY) + minY;

    float2 displacement = float2(-normPrjViewDir.y, normPrjViewDir.x);
    return (1 - saturate(abs(yPos - glitchYPos) * sharpness)) * displacement;
}
