# 🎨 Colortils.nvim
### Color utils for neovim

https://user-images.githubusercontent.com/81827001/171041720-6bc1fc72-dd82-4250-83ec-5c08c907c695.mov

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

#### Color Picker with "block"

![Screenshot 2022-05-30 at 20 02 39](https://user-images.githubusercontent.com/81827001/171042127-6b7fe7f3-a95e-4ce7-b1ea-8026d3c03805.png)


#### Color Picker with "hex"

![Screenshot 2022-05-30 at 20 03 40](https://user-images.githubusercontent.com/81827001/171042234-295e9bbf-d093-491c-98e8-c753f23f6dd1.png)
