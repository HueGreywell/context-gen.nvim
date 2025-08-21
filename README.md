# context-gen.nvim

A Neovim plugin to aggregate project files into a single context file, for use with LLMs.

It generates a file containing a directory tree followed by the contents of selected files.

## Features

- **Directory Tree Generation**: Automatically generates a visual tree of your project structure.
- **Selective File Inclusion**: Hand-pick the files you want to include in the context.
- **Interactive File Management**: Manage your selected files in a floating popup window.
- **Bulk Project Context**: Generate context from all files in the current working directory with one command.
- **Configurable Excludes**: Easily ignore files and directories like `.git`, `.env` ...
- **Customizable Output**: Control the output filename and optionally add a timestamp.

##  Installation

Install with your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "HueGreywell/context-gen.nvim",
  config = function()
    require("context-gen").setup({
      -- Whether to add a timestamp to the output file name
      add_timestamp = false,
      -- Name of the generated context file
      output_file_name = "context",
      -- Directory where the context file will be saved
      output_file = vim.fn.getcwd(),
      -- Files and directories to exclude from the context
      excludes = { ".git", ".env" },
    })
  end,
}
```

## Usage

```lua
require('context-gen').add(file_path)           -- Add a file to the selection
require('context-gen').show_popup()             -- Open interactive popup to manage selection
require('context-gen').generate()               -- Generate context from current selection
require('context-gen').generate_from_cwd()      -- Generate context from all files in current working directory
```


