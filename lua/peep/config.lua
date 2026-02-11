local config = {
    colors = {
        label_main = { fg = "#A72703", bg = "#FCB53B", },
        label_sub = { fg = "#FCB53B", bg = "#44415a", },
        line_aux = { fg = "#9893a5", },
        line_preview = { bg = "#7aa2f7" }
    },

    peep = {
        duration = 700,
        column = false,
        auxline_icon = "·",
        key_trigger = true,
        trigger_keys = { "y", "d", "c", "v", "V" },
        line_preview = true
    }
}
return config
