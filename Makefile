define HELP
Available Commands:

  help:
    Print this help

  sync:
    Import fish, vim and tmux configurations.

  install:
    Export fish, vim and tmux configurations. If these files already exist, the
    user will be prompted.

  clean:
    Do any clean-up, currently a NO-OP

endef

# Dependencies
dep = $(or $(shell which $(1)),$(error Missing required dependency: $(1)))

FISH = $(call dep, fish)
PYTHON = $(call dep, python)

.PHONY: help
help:
	@: $(info $(HELP))

.PHONY: sync
sync:
	cp ~/.vimrc vim/vimrc
	cp ~/.tmux.conf tmux/tmux.conf
	$(FISH) fish/scripts/sync.fish

.PHONY: install
install:
	cp -i vim/vimrc ~/.vimrc
	cp -i tmux/tmux.conf ~/.tmux.conf
	cp -i fish/functions/* ~/.config/fish/functions
	cp -i fish/completions/* ~/.config/fish/completions

.PHONY: clean
clean:
