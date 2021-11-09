# basis

Configurations that define my typical development environment

## Installation

```sh
make install
```

### Fish Configuration

```fish
source fish/install.fish
```

### Vim Configuration

To install the vimrc

```sh
cp vim/vimrc ~/.vimrc
```

To use the vim library (if using [vim-plug](https://github.com/junegunn/vim-plug)).

```viml
Plug 'jmend736/basis', { 'rtp': 'vim' }
```

### Tmux Configuration

```sh
make install
```

## [License](LICENSE)

MIT License

Copyright (c) 2021 Julian Mendoza
