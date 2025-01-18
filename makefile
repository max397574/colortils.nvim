lint:
	stylua lua/

test:
	nvim --headless --noplugin \
	-u tests/custom_init.vim \
	-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/custom_init.vim'}"

ci:
	make test
