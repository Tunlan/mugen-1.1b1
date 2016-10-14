-- Functional programming functions
-- Module name:  fp
-- Started 28 March 2008
-- $Id$
-- Implementations borrowed from various sources on the net and rewritten in Lua.
-- Current functions are:
-- map
-- mapn
-- reduce
-- filter (untested)

fp = {}

-- Applies the function fn to every item in list and returns a new list.
fp.map = function(fn, list)
  local result = {}
  
  for i,v in ipairs(list) do
    result[i] = fn(v)
  end
  return result
end

-- Combines an arbitrary number of lists by using the function fn.
-- Lists should be the same length, however only calculates up to the 
-- length of the shortest list.
-- Returns a list.  
fp.mapn = function(fn, ...)
  local result = {}
  local i = 1
--  local args = ...
  local arg_length = #arg
  
  while true do
    local arg_list = fp.map(function(arr) return arr[i] end, arg)
    if #arg_list < arg_length then return result end
    result[i] = fn(unpack(arg_list))
    i = i+1
  end
end

-- Takes each item of a list and combines them using the function fn.
-- Returns the result (not a list).
fp.reduce = function(fn, list, init)
  local result = init
  
  for i,v in ipairs(list) do
    result = fn(result, v)
  end
  return result
end


-- Calls fn on the list and returns a list with the items that 
-- satisfy the function fn.
fp.filter = function(fn, list)
  local result = {}
  local out
  
  for i,v in ipairs(list) do
    local j = 0
    out = fn(v)
    if out then
      result[j] = out
      j = j + 1
    end
  end
  return result
end  

return fp
