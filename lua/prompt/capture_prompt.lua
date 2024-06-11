local config = require 'prompt.config'
local M = {}

local function get_plugin_path()
  local str = debug.getinfo(1, 'S').source:sub(2)
  return str:match '(.*/)'
end

local function get_context()
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

local function parse_api_model(line)
  local api, model, context

  -- Extract API parameter after '@'
  api = line:match '@(%w+)'

  -- Check if there's a model parameter -m
  model = line:match '%-m%s+([%w-]*)'

  -- Check if there's a context parameter -c
  context = true
  local context_match = line:match '%-%-no%-context'
  print('context_match ', context_match)
  if context_match == '--no-context' then
    context = false
  end

  if not model then
    return api, config.default_model, context
  else
    return api, model, context
  end
end

function M.test()
  print 'hello from capture'
  local api, model, context = parse_api_model '@mistral -m mistral-tiny'
  print(api, model, context)
  api, model, context = parse_api_model '@mistal -m mistral-tiny -c no-context'

  print(api, model, context)
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
