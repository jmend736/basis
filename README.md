# basis

Configurations that define my typical development environment

## Configurations

| File                                  | Install Location              |
|---------------------------------------|-------------------------------|
| [vim/vimrc](vim/vimrc)                | `~/.vimrc`                    |
| [tmux/tmux.conf][tmux/tmux.conf]      | `~/.tmux.conf`                |
| [fish/functions/][fish/functions]     | `~/.config/fish/functions/`   |
| [fish/completions/][fish/completions] | `~/.config/fish/completions/` |

## Installation

To quickly install everything

```sh
make install
```

Otherwise, manually copy configurations as you'd like, see the
[Makefile](Makefile) for more details.

### Vim Plugin Usage

To use the vim library (if using
[vim-plug](https://github.com/junegunn/vim-plug)).

```viml
Plug 'jmend736/basis', { 'rtp': 'vim' }
```

## [License](LICENSE)

MIT License

Copyright (c) 2021 Julian Mendoza
