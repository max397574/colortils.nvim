describe("Get gradients", function()
    it("Get a gradient with length two", function()
        assert.same(
            require("colortils.utils.colors").gradient_colors(
                "#ff0000",
                "#00ff00",
                2
            ),
            { "#FF0000", "#00FF00" }
        )
    end)
    it("Get a gradient with length 5", function()
        assert.same(
            require("colortils.utils.colors").gradient_colors(
                "#ffab00",
                "#abff00",
                5
            ),
            { "#FFAB00", "#EAC000", "#D5D500", "#C0EA00", "#ABFF00" }
        )
    end)
end)
