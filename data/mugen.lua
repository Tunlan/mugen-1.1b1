-- MUGEN module functions

-- Errors/warnings
------------------

mugen.error = function (message, level)
  error(message, level)
end

-- Sandbox
----------

mugen.maxinstructions = 1000000 -- Abort call after this many instructions

do
  local env = {
    assert=assert, error=error, ipairs=ipairs, next=next, pairs=pairs,
    pcall=pcall, print=print, select=select, tonumber=tonumber, tostring=tostring,
    type=type, unpack=unpack, _VERSION=_VERSION, xpcall=xpcall,
    string = {
      byte=string.byte, char=string.char, find=string.find, format=string.format,
      gmatch=string.gmatch, gsub=string.gsub, len=string.len, lower=string.lower,
      match=string.match, rep=string.rep, reverse=string.reverse, sub=string.sub,
      upper=string.upper,
    },
    table = {
      insert=table.insert, maxn=table.maxn, remove=table.remove, sort=table.sort,
    },
    math = {
      abs=math.abs, acos=math.acos, asin=math.asin, atan=math.atan,
      atan2=math.atan2, ceil=math.ceil, cos=math.cos, cosh=math.cosh,
      deg=math.deg, exp=math.exp, floor=math.floor, fmod=math.fmod,
      frexp=math.frexp, huge=math.huge, ldexp=math.ldexp,
      log=math.log, log10=math.log10, max=math.max, min=math.min,
      modf=math.modf, pi=math.pi, pow=math.pow, rad=math.rad,
      sin=math.sin, sinh=math.sinh, sqrt=math.sqrt, tan=math.tan,
      tanh=math.tanh,
    },
    Vector = {
      isvector=Vector.isvector, isnumpair=Vector.isnumpair,
      new=Vector.new, vec1=Vector.vec1, vec2=Vector.vec2,
      changeunitsize=Vector.changeunitsize, add=Vector.add,
      selfadd=Vector.selfadd, sub=Vector.sub,
      selfsub=Vector.selfsub, mul=Vector.mul,
      selfmul=Vector.selfmul, len=Vector.len,
      tostring=Vector.tostring
    },
    --mugen.
  }

  -- Call a function in a sandboxed environment
  mugen.safecall = function (fn)
    -- Prevent long loops
    local maxinstructions = mugen.maxinstructions
    local function abortcheck ()
      debug.sethook()
      mugen.error("Too many instructions executed.")
    end
    debug.sethook(abortcheck, "", maxinstructions)
    -- Run the function in a sandbox
    setfenv(fn, env)
    return pcall(fn)
  end

end

-- Keybind
----------

do
  mugen.keybind = {}
  local keybindmeta = {}

  keybindmeta.__newindex = function (t, k, v)
    if v then
      mugen.keybindadd(k, v)  -- Register it
    else
      mugen.keybinddel(k)  -- Remove it
    end
  end

  keybindmeta.__index = function (t, k)
    return mugen.keybindget(k)
  end

  setmetatable(mugen.keybind, keybindmeta)
end

-- Game flow
------------

do
  local gamemodemap = {
    "title",
    "charsel",
    "options",
    "fight",
    "victory",
    "win",
    "results",
    "continue",
    "vsscreen",
    "cutscene"
  }

  mugen.gamemode = function ()
    return gamemodemap[mugen.gamemodecode()]
  end
end

-- Debug key functions
----------------------

-- Kills a team
mugen.killteam = function (team)
  if mugen.gamemode() ~= "fight" then return; end
  local p
  mugen.log('Killing team ' .. (team or 'all') .. '\n')
  for p in player.player_iter() do
    if not p:ishelper() and (not team or p:teamside() == team) then
      p:lifeset(0)
    end
  end
end

-- Sets a team's life to 1
mugen.almostkillteam = function (team)
  if mugen.gamemode() ~= "fight" then return; end
  local p
  mugen.log('Setting team ' .. (team or 'all') .. ' life to 1\n')
  for p in player.player_iter() do
    if not p:ishelper() and (not team or p:teamside() == team) then
      p:lifeset(1)
    end
  end
end

-- Sets a team's power to full
mugen.maxteampower = function (team)
  if mugen.gamemode() ~= "fight" then return; end
  local p
  mugen.log('Setting team ' .. (team or 'all') .. ' power to max\n')
  for p in player.player_iter() do
    if not p:ishelper() and (not team or p:teamside() == team) then
      if p:power() < p:powermax() then
        p:powerset(p:powermax())
      end
    end
  end
end

-- Toggle AI for a player
mugen.toggleplayerai = function (pidx)
  if mugen.gamemode() ~= "fight" then return; end
  if player.indexisvalid(pidx) then
    p = player.getplayer(pidx)
    if p then
      p:aienableset(not p:aienabled())
      mugen.log('Setting player ' .. tostring(p) .. ' AI to ' .. tostring(p:aienabled()) .. '\n')
    end
  end
end

-- Forces all players into stand state
mugen.forceplayersintostand = function ()
  if mugen.gamemode() ~= "fight" then return; end
  local p
  mugen.log('Forcing players into stand state\n')
  for p in player.player_iter() do
    if not p:ishelper() then
      p:velset{x = 0, y = 0}
      p:changestate{value = 0, ctrl = true, selfstate = true}
    end
  end
end
