# peep.nvim 👀

> A quick peep at relative line numbers

<p align="center">
  <img src="assets/demo.gif" width="720" />
</p>

## Installation

### Lazy.nvim

```lua
use {
    "lum1nar/peep.nvim",
    opts = {
        fg_color = "#f6c177",
        bg_color = "#44415a",
        peep_duration = 800
    },
    keys = {
        { "<leader><leader>", mode = { "n", "v" }, function() require("peep").peep() end, desc = "Peep" },
    }
}
```
