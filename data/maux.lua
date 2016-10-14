-- Helper functions for Lua 5.1 or greater.
-- $Id$

maux = {}

-- Print what items are in a table and their type
maux.dir = function(mytable)
  local t = mytable
  for k,v in pairs(t) do
    if (type(v) == "function") then
      print (k .. '\n')
    end
  end
  for k,v in pairs(t) do
    if (type(v) == "table") then
      print (k .. " (table)" .. '\n')
    end
  end
end

-- Print out the key/value pairs from a table
maux.dir_t = function(mytable)
  local t = mytable
  for k,v in pairs(t) do
    print (tostring(k) .." = " .. tostring(v) .. '\n')
  end
end

maux.isinteger = function(x)
 return math.floor(x) == x
end

return maux
