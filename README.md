# peep.nvim 👀

> A quick peep at relative col/row numbers

<p align="center">
  <img src="assets/demo.gif" width="720" />
</p>

## Features ✨

- 👁 Peek relative numbers in the same column as the cursor
- 🏷 Main + sub labels for easier orientation
- 🎯 Works in Normal & Visual modes
- 🎨 Customizable icon and labels
- ⚡ Optional triggers for d, y, c, v, V
- 🟦 Optional Column Peeping
- 👀 Optional Line Preview (WIP)

## Installation

### Lazy.nvim

```lua
{
    "lum1nar/peep.nvim",
    config = function()
        require("peep").setup({
            colors = {
                label_main = { fg = "#A72703", bg = "#FCB53B", },
                label_sub = { fg = "#FCB53B", bg = "#44415a", },
                line_aux = { fg = "#9893a5", },
            },
            peep = {
                duration = 700,
                column = false,
                auxline_icon = "·",
                key_trigger = true,
                trigger_keys = { "y", "d", "c", "v", "V" },
            }
        })
        vim.keymap.set({ "n", "v" }, "<leader><leader>", function() require("peep").peep() end, { desc = "Peep" })
    end
}
```
