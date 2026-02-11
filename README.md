# peep.nvim 👀

> A quick peep at relative numbers — with instant previews for d, y, c, vV

<p align="center">
  <img src="assets/demo.gif" width="720" />
</p>

## Features ✨

- 👁 See relative numbers in the column under your cursor - with optional column peek support
- 🏷 Dual labels highlight the main target and nearby lines for quick orientation
- 🎯 Works seamlessly in Normal and Visual modes
- ⚡ Trigger motions like d, y, c, v, V with confidence
- 🎨 Customize colors, icons, and line previews to match your setup

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
                line_preview = { fg  = "#7aa2f7" }
            },

            peep = {
                duration = 700,
                column = false,
                auxline_icon = "·",
                key_trigger = true,
                trigger_keys = { "y", "d", "c", "v", "V" },
                line_preview = true
            }
        })
        vim.keymap.set({ "n", "v" }, "<leader><leader>", function() require("peep").peep() end, { desc = "Peep" })
    end
}
```
