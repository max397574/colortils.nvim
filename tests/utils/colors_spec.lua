---@diagnostic disable: undefined-global
describe("Get gradients", function()
    it("Get a gradient with length two", function()
        assert.same(
            require("colortils.utils.colors").gradient_colors("#ff0000", "#00ff00", 2),
            { "#FF0000", "#00FF00" }
        )
    end)
    it("Get a gradient with length 5", function()
        assert.same(
            require("colortils.utils.colors").gradient_colors("#ffab00", "#abff00", 5),
            { "#FFAB00", "#EAC000", "#D5D500", "#C0EA00", "#ABFF00" }
        )
    end)
end)

describe("Get colors from string", function()
    it("String with no colors", function()
        assert.same(require("colortils.utils.colors").get_colors("#FFab0 this is a text"), {})
    end)
    it("Get multiple hex colors", function()
        assert.same(require("colortils.utils.colors").get_colors("#abff00 #ffaB00"), {
            {
                end_pos = 7,
                match = "#abff00",
                rgb_values = { 171, 255, 0 },
                start_pos = 1,
                transparency = false,
                type = "hex",
            },
            {
                end_pos = 15,
                match = "#ffaB00",
                rgb_values = { 255, 171, 0 },
                start_pos = 9,
                transparency = false,
                type = "hex",
            },
        })
    end)
    it("Get rbg and hex color from one string", function()
        assert.same(require("colortils.utils.colors").get_colors("{ background: rgba(100%, 100%, 0%, 1) #ABff00; }"), {
            {
                end_pos = 45,
                match = "#ABff00",
                rgb_values = { 171, 255, 0 },
                start_pos = 39,
                transparency = false,
                type = "hex",
            },
            {
                end_pos = 37,
                match = "rgba(100%, 100%, 0%, 1)",
                rgb_values = { 255, 255, 0 },
                start_pos = 15,
                transparency = true,
                type = "rgba percentage",
            },
        })
    end)
end)
