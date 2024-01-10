# Changelog

## [1.1.0](https://github.com/nvim-colortils/colortils.nvim/compare/v1.0.0...v1.1.0) (2023-04-22)

### Features

- command completion ([6e2b200](https://github.com/nvim-colortils/colortils.nvim/commit/6e2b200dfedd67d96eafd74b08adc08da95ccb4f))
- create highlight group to highlight row ([00baa1e](https://github.com/nvim-colortils/colortils.nvim/commit/00baa1ec60be94bc52b0fed32d2aa32f146cddfb))
- default command ([649fe2f](https://github.com/nvim-colortils/colortils.nvim/commit/649fe2fa956138ac10db05c0de24ae3ed5db4918))

### Bug Fixes

- **picker:** properly restore cursor highlight ([ec48f45](https://github.com/nvim-colortils/colortils.nvim/commit/ec48f45cc4e2b68d70141b915b3393878b5dfa66))

## [1.0.0] - 2022-08-29

### Bug Fixes

- Don't shadow variable
- Remove usage of transparency when undefined
- Close window after resetting help
- Use start index to get matches
- Close help when exporting or choosing format
- Convert numbers to base 10
- Properly close help
- How complete help
- Reset old cursor position
- Allow floats in hsl pattern
- Get bg from NormalFloat for cursor
- Allow multiple digits in floats
- Try to hide cursor properly
- Return empty string/table instead of nil
- Don't try to index color table
- Don't try to index color
- Reset index
- Fix exporting without transparency
- Made widther so colors won't wrap
- Correct preview and use alpha
- Add missing code

### Documentation

- Added changelog
- Document new input method(s)
- Document css colors
- Moved description of transparency
- Added more annotations
- Updated new defaults
- New demo video

### Features

- Allow different formats
- Replace colors (#14)
- Help window (#16)
- Display export in help
- Make much more mappings configurable
- Hide cursor independent of highlight
- Hide cursor properly
- Better way of getting colors
- Allow using css colors as input
- Use alpha if found in color
- Properly hide cursor
- Display transparent gradients
- Pass alpha value into functions
- Add background for transparency
- Change format for transparency
- Export transparency
- Added transparency support
- Add transparency to keybindings help
- Use mappings for config in help
- Initial commit
- Allow blended gradient to fallback
- Added background and mapping to change it
- Added background mapping to help
- Move gradients.lua into folder

### Miscellaneous Tasks

- Autoformat with stylua

### Refactor

- Extract function for color under cursor
- Rename variables
- Cleanup
- Rename variables
- Put some variables into table
- Moved variables into table
- Move more variables into function
- Make transparency value what is displayed
- Use export from utils/tools
- Get rid of if statements
- Merge functions for adjusting
- Get rid of some local variables

### Testing

- Add tests for `get_color`
- Adjust to new return values
- Remove removed functions

### Cleanup

- Removed unused code
- Removed unnecessary nil assignments

### Gitignore

- Add some files for testing and todo
- Added notes

## [1.0.0-alpha] - 2022-07-01

### Bug Fixes

- Use 0.7
- Made bar function work correctly
- Hack for fixing log to file
- Updated function name
- Better highlight group name
- Add border
- Unused_variable check
- Remove copied code
- Svg
- Fix overflow (check for <0 and >255)
- Result always uppercase
- Don't floor steps
- Don't reset `idx` before setting register

### Documentation

- Initial commit
- Added images
- Lazyload
- Updated settings and added instructions for picker
- Added information about css utils
- Added css list screenshot
- Added logo
- Use gif
- Slightly better gif
- Similar plugins
- Document available tools
- Added screenshots

### Features

- Some first values and settings
- Added functions to validate colors
- Added command and picker
- Added log
- Added annotations
- Better preview customization
- Added support for using color under cursor
- Added todos
- Inital commit
- Renamed file
- Added command to list colors
- Ignore unused variables
- Improved logo
- Added license
- Fixed order for colors
- Added setting validation
- Moved utils into folder
- Initial commit
- Renamed utils specs
- Added tests for utils/colors
- Prepare for adding tools
- Allow changing colors faster
- Move picker
- Added more annotations
- Added greyscale
- Added colors
- Use mappings from config
- Better mappings for big in-/decrement
- Copy color to register on <cr>
- Initial commit
- Initial commit
- Ensure color and make commands for tools
- Added function for complementary
- Look better and preview from settings
- Add rgb/hsl functions
- Allow setting a value directly
- Add 0 and $ mappings
- Added 0 and $ mappings
- Better mapping to set value
- Hide cursor
- Allow to use different formats
- Add mapping to allow choosing format
- Fixed cursor position
- Preview with default format
- Preview of color in vim.ui.select
- Fix cursor pos and make visible

### Miscellaneous Tasks

- Autoformat with stylua

### Refactor

- Refactor colors
- Use one tool for all gradient things

### Testing

- Added tests for bars and blocks
- Added tests for color validation

### Ref

- Don't use ... = function
- Use math.min/max instead of if statements
- Use function to set color values
- `set_marker()` in update function
