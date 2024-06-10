local M = {}

Context =
  'You are an expert programmer answering code questions from collaborators. In all your replies, you surround the code blocks into a markdown code block that always include the file extension for syntax highlighting'

function M.setup()
  print 'Prompt plugin loaded'
  Model = 'mistral-tiny'
end

local function get_api_key()
  local config_path = vim.fn.stdpath 'config' .. '/.llm.conf'
  local file = io.open(config_path, 'r')
  if not file then
    error 'API key configuration file not found. Please create mistral_api_key.conf in your Neovim config directory.'
    return nil
  end

  local api_key = file:read '*a'
  file:close()

  api_key = api_key:match 'mistral=(%S+)'
  return api_key
end

local function format_curl_command(input)
  local apikey = get_api_key()

  local jq_command = string.format(
    [[jq -ncM --arg model "%s" --arg content "%s" '
      {
        model: $model,
        messages: [
          {
            role: "user",
            content: $content
          }
        ]
      }'
    ]],
    Model,
    input:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('`', '\\`')
  )

  local curl_command = string.format(
    [[
    curl --location 'https://api.mistral.ai/v1/chat/completions' \
      --header 'Content-Type: application/json' \
      --header 'Accept: application/json' \
      --header 'Authorization: Bearer %s' \
      --data-raw "$(%s)" \
      --silent | jq -r '.choices[0].message.content'
    ]],
    apikey,
    jq_command
  )
  return curl_command
end

-- Extract text between llm marks on the current buffer
function M.capture_prompt()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = {}
  table.insert(input, Context)
  local capturing = false

  for _, line in ipairs(lines) do
    if line:find('@llm', 1, true) then
      if capturing then
        table.insert(input, line:match '^(.-)@llm')
        capturing = false
      else
        capturing = true
        table.insert(input, line:match '@llm(.*)')
      end
    elseif capturing then
      -- Capture the entire line if within marks
      table.insert(input, line)
    end
  end

  local result = table.concat(input, '\n')
  return result
end

local function prepare_reply_text(text)
  local prefix = '{{chat}}\n'
  return prefix .. text
end

-- Insert text before the second @llm tag from a file
function M.reply(text)
  local text_to_insert = prepare_reply_text(text)
  local text_lines = {}
  for line in text_to_insert:gmatch '[^\r\n]+' do
    table.insert(text_lines, line)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local mark_count = 0

  for i, line in ipairs(lines) do
    local mark_positions = {}
    for pos in line:gmatch '()@llm()' do
      table.insert(mark_positions, pos)
    end

    for _, pos in ipairs(mark_positions) do
      mark_count = mark_count + 1
      if mark_count == 2 then
        -- Insert the lines from the file before the second mark
        local before = line:sub(1, pos - 1)
        local after = line:sub(pos)
        table.insert(text_lines, before .. after)
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, text_lines)
        vim.cmd 'redraw!'
        vim.cmd 'syntax sync fromstart'
        return -- Exit after modification to avoid multiple insertions
      end
    end
  end
end

function M.test()
  print 'test'
end

function M.prompt()
  local text = M.capture_prompt()
  local command = format_curl_command(text)
  local answer = vim.fn.system(command)
  M.reply(answer)
end

return M
