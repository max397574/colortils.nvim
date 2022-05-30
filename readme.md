# 🎨 Colortils.nvim
### Color utils for neovim



## ✨ Features
- Color picker with nice ui

## 📦 Installation and Usage

Use you favourite package manager and call the setup function.
```lua
use {
  "max397574/colortils.nvim",
  config = function()
    require("colortils").setup()
  end,
}
```

You can use the `Colortils` command to use this plugin.

#### Color picker
Use `Colortils picker` to access the color picker.
You can provide an optional argument which is the intial color the picker will have.
This is a hex color code without the `#` at the beginning (e.g. FF00AB).

## ⚙️ Customization
You can change the settings by passing options to the setup function.
This is the default configuration:
```lua
require("colortils").setup({
    register="+", -- register in which color codes will be copied: any register
    color_display = "block", -- how to display the color: "block" or "hex"
})
```

## 👀 Demo

