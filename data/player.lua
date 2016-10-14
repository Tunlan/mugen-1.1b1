-- Player module functions

player.interface_functions = {
  "life",
  "lifeset",
  "lifemax",
  "power",
  "powerset",
  "powermax",
  "winperfect",
  "win",
  "winko",
  "wintime",
  "lose",
  "loseko",
  "losetime",
  "drawgame",
  "matchover",
  "animtime",
  "anim",
  "animelemno",
  "animelemtime",
  "animexist",
  "selfanimexist",
  "roundsexisted",
  "teamside",
  "teammode",
  "ishometeam",
  "alive",
  "aienabled",
  "aienableset",
  "ailevel",
  "hitcount",
  "uniqhitcount",
  "movehit",
  "moveguarded",
  "movecontact",
  "movereversed",
  "inguarddist",
  "stateno",
  "prevstateno",
  "statetype",
  "movetype",
  "ctrl",
  "var",
  "fvar",
  "sysvar",
  "sysfvar",
  "hitdefattrmatch",
  "numproj",
  "projcanceltime",
  "projhittime",
  "projguardedtime",
  "projcontacttime",
  "name",
  "authorname",
  "numpartner",
  "numenemy",
  "id",
  "facing",
  "hitfall",
  "hitshakeover",
  "hitover",
  "hitpausetime",
  "canrecover",
  "palno",
  "numexplod",
  "numtarget",
  "ishelper",
  "numhelper",
  "command",
  "warning",
  "error",
  "unitsize",
  -- Sctrls
--  "changestate",
--  "velset",
  -- Misc
  "isvalid",
  "__tostring",
  -- Debug - will be removed
  "rc",
}

player.interface_functions_sig = {
  -- {"function_name", {param1_name = {"param1_type", param1_default}, ... } },
  -- param_type must be one of standard lua types, or "Vector", "Numpair" or "integer".
  {"velset", {x = {"Vector", nil}, y = {"Vector", nil} } },
  {"explod", {anim = {"integer", nil, true}, usefightfx = {"boolean", false}, ownpal = {"boolean", false},
     id = {"integer", 0}, pos = {"Vector", Vector:vec2(0, 0)}, vel = {"Vector", Vector:vec2(0, 0)}, 
     accel = {"Vector", Vector:vec2(0, 0)}, removetime = {"integer", -2},
     supermovetime = {"integer", 0}, pausemovetime = {"integer", 0}, sprpriority = {"integer", 0},
     shadow = {"boolean", false}, removeongethit = {"boolean", false}, hitpausemove = {"boolean", true},
     scale = {"Numpair", Vector:numpair(1, 1)},
     angle = {"number", 0}, yangle = {"number", 0}, xangle = {"number", 0}, 
     } },
  {"changestate", {value = {"integer", nil, true}, ctrl = {"boolean", nil}, anim = {"integer", nil} } },
}

player.interface_functions_vector_retval = {
  "vel",
  "pos",
  "screenpos",
  "backedge",
  "frontedge",
  "frontedgedist",
  "backedgedist",
  "frontedgebodydist",
  "backedgebodydist",
  "hitvel",
  "parentdist",
  "rootdist",
  "const",      -- Some return values
  "gethitvar",  -- Some return values
}

-- Gets an interface to a player by its index
player.getinterface = function (idx)
  local interface = {}
  local p = player.getplayer(idx)
  local k,v
  local player_fns = player.interface_functions
  local imeta = {}
  setmetatable(interface, imeta)
  -- Build interface from table
  for _,fnname in ipairs(player_fns) do
    local fn = p[fnname]
    if (type(fn) == "function") then
      if (string.sub(fnname, 1, 2) == "__") then
        imeta[fnname] = function (...) return fn(p, ...); end
      else
        interface[fnname] = function (...) return fn(p, ...); end
      end
    end
  end
  -- Special cases for vectors
  for _,fnname in ipairs(player.interface_functions_vector_retval) do
    local fn = p[fnname]
    interface[fnname] = function (...)
      local val = fn(p,...)
      if (Vector.isvector(val)) then
        val:selfchangeunitsize(p:unitsize())
        if (val.dimensions == 1) then
          val = val.x
        end
      end
      return val
    end
  end
  -- Vectors in parameters, with possible vector return value
  for _,fndef in ipairs(player.interface_functions_sig) do
    local fnname = fndef[1]
    local fnsig = fndef[2]
    local fn = p[fnname]
    interface[fnname] = function (originalparams, ...)
      -- Validate against sig
      -- e.g. {"x" = {"vector", Vector:vec1(0)}, "y" = {"vector", nil} }
      local params = {}
      local k, v
      -- Defaults
      for k, v in pairs(fnsig) do
        params[k] = v[2]
      end
      -- Parameters passed in
      for k, v in pairs(originalparams) do
        local paramsig = fnsig[k]
        if not paramsig then
          p:error(tostring(fnname) .. ': parameter ' .. tostring(k) .. ' not recognized\n')
        end
        local paramtype = paramsig[1]
        -- Special check for integer numbers
        if paramtype == "integer" and type(v) == "number" then
          if not maux.isinteger(v) then
            p:error(string.format("%s: : parameter %s (%s) is incorrect type: %s (%s expected)\n", 
              fnname, k, tostring(v), "floating point number", paramtype))
          end
        -- Special processing for vector parameters
        elseif paramtype == "Vector" and (Vector.isvector(v) or type(v) == "number") then
          -- Convert number into 1D vector in player coordspace
          if type(v) == "number" then
            v = Vector:vec1(v, p:unitsize())
          end
        -- Type check: numpair
        elseif paramtype == "Numpair" and Vector.isnumpair(v) then
          -- Do nothing
        -- Type check
        elseif type(v) ~= paramtype then
          p:error(string.format("%s: : parameter %s (%s) is incorrect type: %s (%s expected)\n", 
            fnname, k, tostring(v), type(v), paramtype))
        end
        -- Assign
        params[k] = v
      end
      -- Execute function
      local val = fn(p, params)
      -- Process vector return values
      if Vector.isvector(val) then
        val:selfchangeunitsize(p:unitsize())
        if val.dimensions == 1 then
          val = val.x
        end
      end
      return val
    end
  end
  return interface
end

-- Checks if a player with an ID exists
-- @id  ID if the player
-- @return  true if player exists, false if player does not
player.playeridexist = function (id)
  return player.indexfromid(id) ~= nil
end

-- Returns an interator for all players, helpers included.
-- If, during the life of the iterator, a new player is created or an existing
-- player destroyed, that player will not be counted in the iteration.
-- @return  Iterator that returns a player
player.player_iter = function ()
  local i = 0
  local idxlist = player.getplayerlist()
  local n = #idxlist
  return function ()
    local p = nil
    while i < n and not p do
      i = i + 1
      local idx = idxlist[i]
      p = player.getplayer(idx)
      if p then return p; end
    end
  end
end

-- Returns an interator for all players, helpers included.
-- If, during the life of the iterator, a new player is created or an existing
-- player destroyed, that player will not be counted in the iteration.
-- @return  Iterator that returns a player interface
player.interface_iter = function ()
  local i = 0
  local idxlist = player.getplayerlist()
  local n = #idxlist
  return function ()
    local interface = nil
    while i < n and not interface do
      i = i + 1
      local idx = idxlist[i]
      interface = player.getinterface(idx)
      if interface then return interface; end
    end
  end
end

-- Player object functions
--------------------------

-- Prints a warning for the player
-- @message  message to print. A newline will be added to the message.
player._meta.warning = function (self, message, level)
  mugen.warning('Warning: ' .. tostring(self) .. ': ' .. tostring(message) .. '\n', level)
end

-- Prints an error related to the player
player._meta.error = function (self, message, level)
  mugen.error('Error: ' .. tostring(self) .. ': ' .. tostring(message) .. '\n', level)
end

-- Trigger const
-- @return  The value of a player constant.
--   nil if not a valid constant name.
player._meta.const = function (self, name)
  local const = self:rc().const
  local val
  if (type(name) ~= 'string') then
    self:warning("expected string argument")
    return nil
  end
  -- Get the constant
  val = const[name]
  -- Check for .x or .y special cases (vector constants)
  if not val then
    if name:sub(-2) == '.x' then
      local s2 = name:sub(1, -3)
      if const[s2] and type(const[s2] == 'table') then
        val = const[s2].x
      end
    elseif name:sub(-2) == '.y' then
      local s2 = name:sub(1, -3)
      if const[s2] and type(const[s2] == 'table') then
        val = const[s2].y
      end
    end
  end
  if not val then
    self:warning("Const " .. name .. " is not defined")
  end
  return val
end

player._meta = nil
