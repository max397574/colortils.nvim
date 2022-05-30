---@diagnostic disable: undefined-global
describe("Get hex values", function()
    it("Convert any value to hex", function()
        assert.equals(require("colortils.utils").hex(34), "22")
    end)
    it("Get hex value of a 1 digit value", function()
        assert.equals(require("colortils.utils").hex(12), "0C")
    end)
end)
