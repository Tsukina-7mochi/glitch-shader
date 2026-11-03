#ifndef GLITCH_SHADER_UTIL_INCLUDED
#define GLITCH_SHADER_UTIL_INCLUDED

inline fixed maxElement(fixed3 v)
{
  return max(max(v[0], v[1]), v[2]);
}

#endif // GLITCH_SHADER_UTIL_INCLUDED
