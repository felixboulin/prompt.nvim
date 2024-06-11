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

local function mistral_base_command(input, api, model)
  local apikey = get_api_key(api)

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
    model,
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

local function codestral_command(input, api, model)
  local apikey = get_api_key(api)
  local jq_command = string.format(
    [[jq -ncM --arg model "%s" --arg content "%s" '
        {
          model: $model,
          prompt: $content,
          suffix: "",
          max_tokens: 256,
          temperature: 0
        }'
      ]],
    model,
    input:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('`', '\\`')
  )

  local curl_command = string.format(
    [[
      curl --location 'https://api.mistral.ai/v1/fim/completions' \
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

function M.format_curl_command(input, api, model)
  if api == 'mistral' then
    if model == 'codestral-latest' then
      print 'using mistral codestral command'
      return codestral_command(input, api, model)
    else
      print 'using mistral standard command'
      return mistral_base_command(input, api, model)
    end
  elseif api == 'claude' then
    print 'using claude'
  else
    error('Unknown API: ' .. api)
  end
end

return M
