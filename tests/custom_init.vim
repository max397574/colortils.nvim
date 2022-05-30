set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=./plenary.nvim
set rtp+=~/.local/share/nvim/site/pack/packer/opt/plenary.nvim
set rtp+=~/.local/share/nvim/site/pack/packer/start/plenary.nvim

runtime! plugin/plenary.vim

lua <<EOF
P = function(...)
    if type(...) == "userdata" then
        print("Userdata:")
        print(vim.inspect(getmetatable(...)))
    else
        print(vim.inspect(...))
    end
    return ...
end
-- TODO: Try to fix problem with log
vim.g.running_from_colortils_test=true
EOF
