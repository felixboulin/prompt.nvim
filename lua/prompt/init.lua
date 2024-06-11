local capture = require 'prompt.capture_prompt'
local curl = require 'prompt.format_curl_command'
local reply = require 'prompt.reply'
local config = require 'prompt.config'
local M = {}

function M.setup(user_config)
  user_config = user_config or {}
  config = vim.tbl_deep_extend('force', config, user_config)
end

function M.test()
  local text, api, model = capture.capture_prompt()
  print('using ', api, model)
  local command = curl.format_curl_command(text, api, model)
  print(command)
  local answer = vim.fn.system(command)
  print(answer)
end

function M.prompt()
  local text, api, model = capture.capture_prompt()
  print('using ', api, model)
  local command = curl.format_curl_command(text, api, model)
  local answer = vim.fn.system(command)
  print(#answer)
  if #answer == 5 then
    error 'Curl command failed, please check api key and api/model are correct'
  else
    reply.reply(answer)
  end
end

return M
