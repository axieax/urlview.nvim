test:
	nvim --headless --noplugin -u tests/init.vim -c "PlenaryBustedDirectory tests/urlview {minimal_init = 'tests/init.vim'}"
