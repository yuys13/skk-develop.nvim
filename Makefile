.PHONY: test

test:
	nvim --headless -u test/init.vim -c "PlenaryBustedDirectory test/"
