# prompt.nvim
Plugin to chat with LLMs directly from neovim. Makes it convenient to refine prompts and yank pieces of answers straight from a project. 

To use it, simply wrap your prompt in your current buffer by inserting two tags: 
one to start with `@` and the name of the model, and one to end: `@end`.
Any text in between will be sent as a prompt, and the answer will be inserted before the `@end` tag.

Then run `:lua require("prompt.init").prompt()` to get the answer inserted in your buffer.

Note: operate from markdown buffer to get the code highlighting from your setup when editing conversations with LLMs.

## Installation
Requires JQ and Curl.
In you neovim config folder (`~/.config/nvim` by default), create a new file named `.llm.conf` and inside, add your api key for Mistral AI as follows:
```
mistral=<YOUR_API_KEY>
```

## Available models
Work in progress - only supports MistralAI.
```
`@mistral` -> will use mistral
`@claude` -> will use claude
`@chatgpt` -> will use chatgpt
```
Optional, specify a model in the prompt (otherwise use default)
`@<llm>.<model>`. Examples (refer to the official api documentation to view all available models):

Currently supported models:
```
@mistral.open-mistral-7b #default
@mistral.mistral-small-latest
@mistral.mistral-medium-latest
@mistral.mistral-large-latest
@misrtal.codestal-latest
@mistral # will use the default
```

## example
```md
@mistral -m mistral-small-latest
Write a factorial function in plain C.
@end
```

Your markdown buffer will be filled with the answer.
```
@mistral -m mistral-small-latest
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

If you don't want to produce specifically code, and remove the default context which conditions the LLM to answer with well structured code samples, you can add the `--no-context` argument to the tags
```
@mistral --no-context
Write an executive summary for the project
@end
```

