local Schema = {}

local GAMEDIR_SCHEMA = {
  type = 'struct',
  required = {'path'},
  items = {path = {type = 'string'}, default = {type = 'boolean'}}
}

local EXPANSION_SCHEMA = {
  type = 'struct',
  required = {'recipe'},
  items = {
    default = {type = 'boolean'},
    recipe = {type = 'list', items = {type = 'string'}},
    locale = {type = 'string'}
  }
}

local PICSET_SCHEMA = {
  type = 'struct',
  required = {'mode'},
  items = {
    mode = {type = 'string'},
    default = {type = 'boolean'},
    size = {type = 'string'},
    ext = {type = 'string'},
    artsize = {type = 'string'},
    year = {type = 'number'},
    author = {type = 'string'},
    field = {type = 'boolean'},
    holo = {type = 'boolean'},
    locale = {type = 'string'},
    ['color-normal'] = {type = 'string'},
    ['color-effect'] = {type = 'string'},
    ['color-spell'] = {type = 'string'},
    ['color-trap'] = {type = 'string'},
    ['color-ritual'] = {type = 'string'},
    ['color-fusion'] = {type = 'string'},
    ['color-synchro'] = {type = 'string'},
    ['color-xyz'] = {type = 'string'},
    ['color-link'] = {type = 'string'}
  }
}

local SCHEMA = {
  type = 'struct',
  required = {'locale', 'gamedir', 'expansion', 'picset'},
  items = {
    locale = {type = 'string'},
    gamedir = {type = 'map', default = {}, items = GAMEDIR_SCHEMA},
    expansion = {type = 'map', default = {}, items = EXPANSION_SCHEMA},
    picset = {type = 'map', default = {}, items = PICSET_SCHEMA}
  }
}

Schema.default = SCHEMA

local validate = {}

function validate.any(v, schema, strict)
  if schema.type == 'any' then return v end
  return validate[schema.type](v, schema, strict)
end

function validate.struct(t, schema, strict)
  local st = {}
  if type(t) ~= 'table' then
    if strict then return nil end
    t = {}
  end
  for _, k in ipairs(schema.required or {}) do
    if t[k] == nil then
      if strict then return nil end
      st[k] = schema.items[k].default
    end
  end
  for k, v in pairs(t) do
    if schema.items[k] then
      st[k] = validate.any(v, schema.items[k], strict)
    end
  end
  return st
end

function validate.map(t, schema, strict)
  local map = {}
  if type(t) ~= 'table' then return not strict and {} or nil end
  for k, v in pairs(t) do
    map[k] = validate.any(v, schema.items)
  end
  return map
end

function validate.list(t, schema, strict)
  local list = {}
  if type(t) ~= 'table' then return not strict and {} or nil end
  for i, v in ipairs(t) do
    list[i] = validate.any(v, schema.items)
  end
  return list
end

function validate.string(t) return type(t) == 'string' and t or nil end
function validate.boolean(t) return type(t) == 'boolean' and t or nil end
function validate.number(t) return type(t) == 'number' and t or nil end

--- Validates table `t` according to the configuration schema. Validation works in a
--- "best effort" manner, producing a minimally acceptable version of
--- the original table. If `strict` is enabled, any invalid attribute
--- is turned into `nil`.
--- @param t table
--- @param strict boolean
--- @return table
function Schema.validate(t, strict)
  return validate.any(t, SCHEMA, strict)
end

return Schema
