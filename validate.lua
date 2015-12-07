local ucl = require "ucl"

local function _get_object_wrapped(str)
  if not str then return nil, "empty object" end
  local parser = ucl.parser()

  if not string.find(str,'["{[]') then
    ok, err = parser:parse_file(str)
  else
    ok, err = parser:parse_string(str)
  end

  if not ok then
    return nil, err
  end

  return parser:get_object_wrapped()
end

local function validate(json,schema)
  local input, err = _get_object_wrapped(json)
  if not input then return nil, err end

  local schema_file = string.match(schema,'^([^#]+)')

  local schema_section = string.match(schema, '(#/.+)$')

  local schema, err = _get_object_wrapped(schema_file)
  if not schema then return nil, err end

  return input:validate(schema,schema_section)
end

local input = [[
{
  "localpart":"testuser",
  "password":"p@ssword",
  "domain":"foobar.org"
}
]]

for _,schema in ipairs{"works","should_work", "remote", "remote_relative"} do
  local ok, err = validate(input, 'schema.json#/'..schema..'/methods/post')
  if ok then err = ok end

  print(string.format('%-20s => %s', schema, err)) 
end
