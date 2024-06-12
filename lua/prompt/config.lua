local config = {
  mistral = {
    default = 'open-mistral-7b',
    small = 'open-mistral-7b',
    medium = 'mistral-small-latest',
    large = 'mistral-large-latest',
  },
  claude = {
    default = 'claude-3-haiku-20240307',
    small = 'claude-3-haiku-20240307',
    medium = 'claude-3-sonnet-20240229',
    large = 'claude-3-opus-20240229',
  },
  chatgpt = {
    default = 'gpt-3.5-turbo',
    small = 'gpt-3.5-turbo',
    medium = 'gpt-4o',
    large = 'gpt-4-turbo',
  },
}

return config
