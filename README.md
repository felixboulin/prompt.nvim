# prompt.nvim
Plugin to chat with LLMs directly from neovim. Convenient to refine prompts and yank pieces of answers straight from a project. 

To use it, simply wrap your prompt in your current buffer by inserting two tags: 
one to start with `@` and the name of the llm (@chatgpt, @claude or @mistral), and one to end: `@end`.
Any text in between will be sent as a prompt, and the answer will be inserted before the `@end` tag.

Then run `:lua require("prompt.init").prompt()` to get the answer inserted in your buffer.

Note: operate from markdown buffer to get the code highlighting from your setup when editing conversations with LLMs.

## Installation
Requires JQ and Curl.
In you neovim config folder (`~/.config/nvim` by default), create a new file named `.llm.conf` and inside, add your api key for the api you'll use:
```
mistral=<MISTRAL_API_KEY>
claude=<CLAUDE_API_KEY>
chatgpt=<OPENAI_API_KEY>
```

## Available models
```
@mistral -> will use mistral
@claude -> will use claude
@chatgpt -> will use chatgpt
```
You can map tiers of model tags per llm. The default config is per below, you can overwrite it in setup to chose any available model for each llm.
```
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
```
```
@chatgpt medium --> will use gpt-4o
@mistral large --> will use mistral-large-latest
```
You can also overwrite the model with a m tag
```
@chatgpt small -m gpt-4o --> will use gpt-4o
```


## example
```md
@mistral
Write a factorial function in plain C.
@end
```

Your markdown buffer will be filled with the answer.
```
@mistral
write a factorial function in plain c
{{chat}}
Sure, here's a simple implementation of a factorial function in C:
``c
#include <stdio.h>
unsigned long long factorial(int n) {
    if (n == 0 || n == 1)
        return 1;
    else
        return n * factorial(n - 1);
}
int main() {
    int num;
    printf("Enter a number: ");
    scanf("%d", &num);
    printf("Factorial of %d is %llu\n", num, factorial(num));
    return 0;
}
``
This program first asks the user to input a number, then calculates and prints the factorial of that number. The factorial function itself is implemented using recursion.
@end
```

If you don't want to produce specifically code, and remove the default context which conditions the LLM to answer with well structured code samples, you can add the `no-context` argument to the tags
```
@mistral no-context
Write an executive summary for the project
@end
```

