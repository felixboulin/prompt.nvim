# prompt.nvim
Plugin to chat with LLMs directly from neovim. Makes it convenient to refine prompts and yank pieces of answers straiht from a project. 

To use it, simply wrap your prompt in your current buffer by inserting two `@llm` tags - one to start and one to end. Any text in between will be sent as a prompt, and the answer will be inserted before the second `@llm` tag. Ensure those tags are unique - 2 and only 2 in the file.

Then run `:lua require("prompt.init").prompt()` to get the answer inserted in your buffer.

Note: operate from markdown buffer to get the code highlighting from your setup when editing conversations with LLMs.

Work in progress - only supports MistralAI.

# Installation
Requires JQ and Curl.
In you neovim config folder (`~/.config/nvim` by default), create a new file named `.llm.conf` and inside, add your api key for Mistral AI as follows:
```
mistral=<YOUR_API_KEY>
```
