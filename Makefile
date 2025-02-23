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

Generation Commands:

  vim/doc/tags:
    Generate tags for the help pages

endef

# Dependencies
dep = $(or $(shell which $(1)),$(error Missing required dependency: $(1)))

FISH = $(call dep, fish)
VIM = $(call dep, vim)

.PHONY: help
help:
	@: $(info $(HELP))

.PHONY: sync
sync: vim/doc/tags
	cp ~/.vimrc vim/vimrc
	cp ~/.tmux.conf tmux/tmux.conf
	$(FISH) fish/scripts/sync.fish

.PHONY: deploy
deploy:
	git pull
	git add .
	git commit -m sync
	git push

.PHONY: install
install:
	cp -i vim/vimrc ~/.vimrc
	cp -i tmux/tmux.conf ~/.tmux.conf
	cp -i fish/functions/* ~/.config/fish/functions
	cp -i fish/completions/* ~/.config/fish/completions

vim/doc/tags: vim/doc/basis.txt
	$(VIM) +'helptags vim/doc/' +q

.PHONY: clean
clean:
