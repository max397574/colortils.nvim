---@diagnostic disable: undefined-global
describe("Test css module", function()
    it("Get a color", function()
        assert.equals(require("colortils.css").get_color("tomato"), "#FF6347")
    end)
    it("Get an invalid color", function()
        assert.equals(require("colortils.css").get_color("amazing_color"), nil)
    end)
end)
