# peep.nvim 👀

> A quick peep at relative col/row numbers

<p align="center">
  <img src="assets/demo.gif" width="720" />
</p>

## Features ✨

- Display relative numbers in the same column as the cursor for quick navigation
- Each label comes with a sub-label for easier reading and orientation
- Supports both Normal and Visual modes
- Minimal and clean design to avoid visual clutter
- Can be triggered with `d`, `y`, `c` (WIP)
- Customizable icon and labels

## Installation

### Lazy.nvim

```lua
{
    "lum1nar/peep.nvim",
    opts = {
        colors = {
            label_main = {
                fg = "#A72703",
                bg = "#FCB53B",
            },
            label_sub = {
                fg = "#FCB53B",
                bg = "#44415a",
            },
            line_aux = {
                fg = "#9893a5",
            }
        },
        peep = {
            duration = 700,
            column = false,
            auxline_icon = "·"
        }
    },
    keys = {
        { "<leader><leader>", mode = { "n", "v" }, function() require("peep").peep() end, desc = "Peep" },
    }
}
```
