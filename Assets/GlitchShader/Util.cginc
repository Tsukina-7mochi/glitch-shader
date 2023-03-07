#pragma once

inline fixed maxElement(fixed3 v)
{
  return max(max(v[0], v[1]), v[2]);
}