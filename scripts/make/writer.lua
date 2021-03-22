local path = require 'lib.path'
local Codes = require 'lib.codes'
local fun = require 'lib.fun'

local Writer = {
  merge_strings = require 'scripts.make.write-strings'.merge,
  write_strings = require 'scripts.make.write-strings'.write,
  write_entries = require 'scripts.make.write-cdb'
}

local script_template = [[-- %s
local s, id = GetID()
function s.initial_effect(c)
  %s
end]]
local st_activate = [[-- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)]]
local types = Codes.const.type
local function is_effect_monster(t)
  return bit.band(t, types.EFFECT + types.PENDULUM) ~= 0
end
local function is_spell_trap(t)
  return bit.band(t, types.SPELL + types.TRAP) ~= 0
end
--- Writes script file templates if a script file doesn't exist already
--- @param entries CardData[]
function Writer.write_scripts(entries)
  fun.iter(entries)
    :map(function(e) return e, path.join('script', ('c%d.lua'):format(e.id)) end)
    :filter(function(_, fp) return not path.exists(fp) end)
    :each(function(entry, fp)
      local script
      if is_effect_monster(entry.type) then
        script = script_template:format(entry.name, '-- effects')
      elseif is_spell_trap(entry.type) then
        script = script_template:format(entry.name, st_activate)
      else return end
      local f = io.open(fp, 'w')
      if f then
        f:write(script, '\n')
        f:close()
      end
    end)
end

return Writer
