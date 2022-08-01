local color_utils = require("colortils.utils.colors")
return function(color, alpha)
    local grey = color_utils.get_grey(color)
    require("colortils.tools.gradients")(color, grey, alpha)
end
