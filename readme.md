<div align="center">

<img src="res/colortils.svg" width=300>

# Colortils.nvim - Neovim color utils

</div>

<img src=https://user-images.githubusercontent.com/81827001/172020187-8011c927-13b4-4f75-b0c3-e76117136416.gif width="500"/>

## ✨ Features
- rgb color picker
    - Export in different formats
        - rgb
        - hex
        - hsl
    - Transparency support for picking, previewing and exporting
- Lighten and darken colors
- Convert colors to greyscale or something between the color and it's grey version
- Pick a color on a gradient between two colors
- Some utilities for css colors
    - List Colors

## 📦 Installation and Usage

Use you favourite package manager and call the setup function.
```lua
use {
  "max397574/colortils.nvim",
  cmd = "Colortils",
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

You can use `h`/`l` to change the color value under the cursor.
With `<cr>` you can yank the hex color code into the register specified in settings (see defaults below).

#### Css Utilities
##### List colors
Use `:Colortils css list` to get a list of all the colors in a floating window.
This will *try* (**it's not a dependency**) to attach [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua) ([maintained fork](https://github.com/xiyaowong/nvim-colorizer.lua)).

## ⚙️ Customization
You can change the settings by passing options to the setup function.
This is the default configuration:
```lua
require("colortils").setup({
    -- Register in which color codes will be copied
    register = "+",
    -- Preview for colors, if it contains `%s` this will be replaced with a hex color code of the color
    color_preview =  "█ %s",
    -- The default in which colors should be saved
    -- This can be hex, hsl or rgb
    default_format = "hex",
    -- Border for the float
    border = "rounded",
    -- Some mappings which are used inside the tools
    mappings = {
        increment_big = "L",
        decrement_big = "H",
    }
})
```

## 👀 Tools

### Usage
You can use the different tools with commands.
Those take the format `Colortils <tool> <color>`.
The color can either just be a 6 digit hex code (e.g. `FFAB00`) or one with a `#`.
Notice that the `#` needs to be escaped like this `#FF00AB`.

If no color is provided colortils checks if there is a color under the cursor and if so uses this one.
If there is no color under the cursor the user gets asked for input.

#### Mappings
You can use `h`/`l` and the mappings specified in the config to increment and decrement values or pick a position on a gradient.
With `0` and `$` to go to the minimum and the maximum values instantly.

With `q` you can close the tools.

With most tools you can use `<cr>` to save the currently selected color to the register speicified in the config.
If this isn't the case or something is special it will be written below.

#### Color Picker
`Colortils picker <color>`

![picker](https://user-images.githubusercontent.com/81827001/176244717-c4a3d4c5-bb95-4abc-93e0-3733bf87ddb0.png)

##### Transparency mode
You can use `T` to toggle transparency mode.
This will add another slider where you can choose the transparency.
The preview and the color you'll export will change accordingly.

##### Saving color
You can use `<cr>` to save the color into the register specified in the config.
The default format (specified in the config) will be used.

You can use `g<cr>` to get prompted to choose a color format in which the color then will be saved to the register.

#### Lighten color
`Colortils lighten <color>`

![lighten](https://user-images.githubusercontent.com/81827001/176244769-0967873c-8782-4bfb-ba7e-79b2d2a60a54.png)

#### Darken color
`Colortils darken <color>`

![darken](https://user-images.githubusercontent.com/81827001/176244817-fa21c4c9-9700-4889-a379-5bbddb576234.png)

#### Color to greyscale
`Colortils greyscale <color>`

![greyscale](https://user-images.githubusercontent.com/81827001/176244870-697a7d17-3b06-4bd1-ba07-9a59177096c4.png)

#### Pick color on gradient
`Colortils gradient <color1> <color2>`

![gradients](https://user-images.githubusercontent.com/81827001/176244977-3831bc86-f3e7-44fc-b4d9-d615d1ae9d16.png)

#### List css colors
`Colortils css list`

![css_list](https://user-images.githubusercontent.com/81827001/171230907-313fddc8-29e6-4b97-a842-8ea69ed5b6d5.png)

# Similar Plugins
This plugin has some things which are similar to [vim-colortemplate](https://github.com/lifepillar/vim-colortemplate).
