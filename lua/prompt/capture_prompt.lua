local config = require 'prompt.config'
local M = {}

local function get_plugin_path()
  local str = debug.getinfo(1, 'S').source:sub(2)
  return str:match '(.*/)'
end

local function get_context()
  -- Use the plugin directory instead of the user config directory
  local context_file_path = get_plugin_path() .. 'context.txt'
  print(context_file_path)
  local context_file = io.open(context_file_path, 'r')
  if not context_file then
    error('Missing context file at ' .. context_file_path)
  end
  local context = context_file:read '*a'
  context_file:close()
  return context
end

local function trim(s)
  return s:gsub('^%s*(.-)%s*$', '%1')
end

local function parse_api_model(line)
  local api = line:match '@(%w+)' -- Extract API parameter after '@'
  if not api or not config[api] then
    error 'Invalid or unspecified API in the input line.'
  end

  local model = line:match '%-m%s+([%w-]*)' -- Check if there's a model parameter -m
  if model == nil then
    model = config[api].default
    local tier = line:match '%ssmall%s?' or line:match '%smedium%s?' or line:match '%slarge%s?'
    if tier ~= nil then
      model = config[api][trim(tier)]
    end
  end

  -- check if context disabled
  local context = true --default
  local context_match = line:match '%sno%-context%s?'
  print('context match ', context_match)
  if context_match ~= nil and trim(context_match) == 'no-context' then
    context = false
  end

  return api, model, context
end

function M.test()
  local api, model, context = parse_api_model '@mistral medium no-context'
  print(api, model, context)
  if api == 'mistral' and model == config.mistral.medium and context == false then
    print 'In buffer command parses successfully'
  else
    print 'ERROR parsing buffer commands'
  end
  -- print 'hello from capture'
  -- local api, model, context = parse_api_model '@mistral -m mistral-tiny'
  -- print(api, model, context)
  -- api, model, context = parse_api_model '@mistal -m mistral-tiny -c no-context'
  --
  -- print(api, model, context)
end

function M.capture_prompt()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = {}
  local capturing = false
  local api, model, context = nil, nil, nil
  local context_text = ''

  for _, line in ipairs(lines) do
    if line:find('@end', 1, true) then
      if capturing then
        break
      end
    elseif line:match '@(%w+)[.]?(%w*)' then
      if not capturing then
        api, model, context = parse_api_model(line)
        if context == true then
          context_text = get_context()
        end
        table.insert(input, context_text)
        capturing = true
      end
    elseif capturing then
      table.insert(input, line)
    end
  end

  if not capturing then
    error 'No @llm tag found in the document.'
  end

  local result = table.concat(input, '\n')
  return result, api, model
end

return M
