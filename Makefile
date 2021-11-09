define HELP
Available Commands:

  help:
    Print this help

  sync:
    Import ~/.vimrc and ~/.tmux.conf

  install:
    Export ~/.vimrc and ~/.tmux.conf. If these files already exist, the user
    will be prompted.

  clean:
    Do any clean-up, currently a NO-OP

endef


# Dependencies
dep = $(or $(shell which $(1)),$(error Missing required dependency: $(1)))

PYTHON = $(call dep, python)

.PHONY: help
help:
	@: $(info $(HELP))

.PHONY: sync
sync:
	cp ~/.vimrc vim/vimrc
	cp ~/.tmux.conf tmux/tmux.conf

.PHONY: install
install:
	cp -i vim/vimrc ~/.vimrc
	cp -i tmux/tmux.conf ~/.tmux.conf

.PHONY: clean
clean:
