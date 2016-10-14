mugen.log('Lua initing\n')

require "vector"
require "maux"
require "fp"

require "player"
require "mugen"

-- Duplicate maux functions into global namespace
function initlibs()
  local k, v
  for k,v in pairs(maux) do
    if (type(v) == "function") then
      _G[k] = v
    end
  end
end
initlibs()

-- Print, warning and error functions
mugen.warning = mugen.clipboardprint  --Print warnings to clipboard

-- Print to console and log
print = function(s)
  local s = tostring(s)
  mugen.consoleprint(s)
  mugen.log(s)
end

-- Make some things available in global namespace
keybind = mugen.keybind
toggleconsole = mugen.toggleconsole

mugen.isinit = true
mugen.log('Lua init complete\n')
