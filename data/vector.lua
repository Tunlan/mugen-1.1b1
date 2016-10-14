-- Vector class

Vector = {}

-- Returns True if the object is a vector
function Vector.isvector(v)
  return type(v) == "table" and getmetatable(v) == Vector and v.unitsize ~= 0
end

-- Returns True if the object is a numpair
function Vector.isnumpair(v)
  return type(v) == "table" and getmetatable(v) == Vector and v.unitsize == 0
end

-- Constructor for a vector with 1 to 3 dimensions
function Vector:new(x, y, z, unitsize)
  local object = {}
  if type(x) == "table" then
    local args = x
    object = { x = args.x or 0, y = args.y or 0, z = args.z or 0, unitsize = args.unitsize or 1}
    if not args.z then object.no_z = true; end
    object.dimensions = args.z and 3 or (args.y and 2 or 1)
  else
    object = { x = x or 0, y = y or 0, z = z or 0, unitsize = unitsize or 1}
    object.dimensions = z and 3 or (y and 2 or 1)
  end
  setmetatable(object, self)
  self.__index = self
  return object
end

-- Constructor for a vector with 1 dimension
function Vector:vec1(x, unitsize)
  return Vector:new{x = x, unitsize = unitsize}
end

-- Constructor for a vector with 2 dimensions
function Vector:vec2(x, y, unitsize)
  return Vector:new{x = x, y = y, unitsize = unitsize}
end

-- Constructor for a number pair
function Vector:numpair(x, y)
  return Vector:new{x = x, y = y, unitsize = 0}
end

-- Change the unitsize of a vector without changing its magnitude in game units
function Vector.changeunitsize(v, unitsize)
  local unitscale = v.unitsize / unitsize
  return Vector:new(v.x * unitscale,
      v.y * unitscale,
      v.z * unitscale,
      unitsize)
end

-- Change the unitsize of a vector without changing its magnitude in game units
function Vector:selfchangeunitsize(unitsize)
  local unitscale = self.unitsize / unitsize
  self.x = self.x * unitscale
  self.y = self.y * unitscale
  self.z = self.z * unitscale
  self.unitsize = unitsize
  return self
end

-- Add two vectors
function Vector.add(v1, v2)
  local v2unitscale = v1.unitsize / v2.unitsize
  return Vector:new(v1.x + v2.x * v2unitscale, v1.y + v2.y * v2unitscale,
      v1.z + v2.z * v2unitscale, v1.unitsize)
end

-- Add to another vector
function Vector:selfadd(v)
  local unitscale = self.unitsize / v.unitsize
  self.x = self.x + v.x * unitscale
  self.y = self.y + v.y * unitscale
  self.z = self.z + v.z * unitscale
  return self
end

-- Subtract two vectors: v1 - v2
function Vector.sub(v1, v2)
  local v2unitscale = v1.unitsize / v2.unitsize
  return Vector:new(v1.x - v2.x * v2unitscale, v1.y - v2.y * v2unitscale,
      v1.z - v2.z * v2unitscale, v1.unitsize)
end

-- Subtract another vector from this: self - v
function Vector:selfsub(v)
  local unitscale = self.unitsize / v.unitsize
  self.x = self.x - v.x * unitscale
  self.y = self.y - v.y * unitscale
  self.z = self.z - v.z * unitscale
  return self
end

-- Multiply a vector with a scalar
function Vector.mul(v1, s)
  return Vector:new(v1.x * s, v1.y * s, v1.z * s, v1.unitsize)
end

-- Multiply with scalar
function Vector:selfmul(s)
  self.x = self.x * s
  self.y = self.y * s
  self.z = self.z * s
  return self
end

-- Magnitude of vector
function Vector.len(v)
  return math.sqrt(v.x^2 + v.y^2 + v.z^2)
end

-- String
function Vector.tostring(v)
  if v.dimensions == 1 then
    return "(" .. v.x .. ")"
  elseif v.dimensions == 2 then
    return "(" .. v.x .. "," .. v.y .. ")"
  else
    return "(" .. v.x .. "," .. v.y .. "," .. v.z .. ")"
  end
end
Vector.__tostring = Vector.tostring

return Vector
