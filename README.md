# basis

Configurations that define my typical development environment

## Installation

To manually install, manually move files to:

| File                                  | Install Location              |
|---------------------------------------|-------------------------------|
| [vim/vimrc](vim/vimrc)                | `~/.vimrc`                    |
| [tmux/tmux.conf](tmux/tmux.conf)      | `~/.tmux.conf`                |
| [fish/functions/](fish/functions)     | `~/.config/fish/functions/`   |
| [fish/completions/](fish/completions) | `~/.config/fish/completions/` |

To quickly install everything:

```sh
make install
```

### Vim Plugin Usage

To use the vim library (if using
[vim-plug](https://github.com/junegunn/vim-plug)).

```viml
Plug 'jmend736/basis', { 'rtp': 'vim' }
```

## [License](LICENSE)

MIT License

Copyright (c) 2025 Julian Mendoza
