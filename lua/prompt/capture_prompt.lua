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

local function parse_api_model(tag)
  local api, model = tag:match '@(%w+)[.]?([%w-]*)'
  print(api, model)
  if not api then
    return config.default_api, config.default_model
  elseif model == '' then
    return api, config.default_model
  else
    return api, model
  end
end

function M.test()
  print 'hello from capture'
  print(get_context())
end

function M.capture_prompt()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = {}
  local capturing = false
  local api, model = nil, nil
  local context = get_context()

  table.insert(input, context)

  for _, line in ipairs(lines) do
    if line:find('@end', 1, true) then
      if capturing then
        break
      end
    elseif line:match '@(%w+)[.]?(%w*)' then
      if not capturing then
        api, model = parse_api_model(line)
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
