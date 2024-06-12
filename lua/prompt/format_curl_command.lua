local M = {}
local function get_api_key(api)
  local config_path = vim.fn.stdpath 'config' .. '/.llm.conf'
  local file = io.open(config_path, 'r')
  if not file then
    error 'API key configuration file not found. Please create mistral_api_key.conf in your Neovim config directory.'
    return nil
  end

  local api_keys_content = file:read '*a'
  file:close()

  local pattern = string.format('%s=(%%S+)', api)
  local api_key = api_keys_content:match(pattern)
  if not api_key then
    error(string.format('No API key found for %s. Check your .llm.conf configuration.', api))
    return nil
  end

  return api_key
end

local function escape_json(text)
  return text:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('`', '\\`')
end

local function format_data(model, input)
  return string.format(
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
    model,
    escape_json(input)
  )
end

local function mistral_chat_command(input, api_key, model)
  local curl_command = string.format(
    [[
      curl --location 'https://api.mistral.ai/v1/chat/completions' \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --header 'Authorization: Bearer %s' \
        --data-raw "$(%s)" \
        --silent | jq -r '.choices[0].message.content'
      ]],
    api_key,
    format_data(model, input)
  )
  return curl_command
end

local function gpt_chat_command(input, api_key, model)
  local curl_command = string.format(
    [[
      curl https://api.openai.com/v1/chat/completions \
           --header "Authorization: Bearer %s" \
           --header "content-type: application/json" \
           --data-raw "$(%s)" \
           --silent | jq -r '.choices[0].message.content'
      ]],
    api_key,
    format_data(model, input)
  )
  return curl_command
end

local function claude_chat_command(input, api_key, model)
  local jq_command = string.format(
    [[jq -ncM --arg model "%s" --arg content "%s" '
        {
          model: $model,
          max_tokens: 1024,
          messages: [
            {
              role: "user",
              content: $content
            }
          ]
        }'
      ]],
    model,
    escape_json(input)
  )

  local curl_command = string.format(
    [[
      curl https://api.anthropic.com/v1/messages \
           --header "x-api-key: %s" \
           --header "anthropic-version: 2023-06-01" \
           --header "content-type: application/json" \
           --data-raw "$(%s)" \
           --silent | jq -r '.content[0].text'
      ]],
    api_key,
    jq_command
  )
  return curl_command
end

function M.format_curl_command(input, api, model)
  local api_key = get_api_key(api)
  if api == 'mistral' then
    print 'using mistral'
    return mistral_chat_command(input, api_key, model)
    -- end
  elseif api == 'claude' then
    print 'using claude'
    return claude_chat_command(input, api_key, model)
  elseif api == 'chatgpt' then
    print ' using chatgpt'
    return gpt_chat_command(input, api_key, model)
  else
    error('Unknown API: ' .. api)
  end
end

return M
