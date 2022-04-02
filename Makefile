test:
	nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/urlview {minimal_init = 'tests/minimal.vim'}"
