# Introduction

`nvim-typora` is a plugin that aims to provide improved functionality with [Typora](https://typora.io) and its enhanced markdown features.

It is not meant to replace existing markdown plugins, only enhance their functionality with specific additions for Typora.

# Features

This plugin is still a work in progress. That said, it is in a good state for others to begin getting use out of it:

* Basic `mermaid` snippets
	* [x] Class Diagrams
	* [x] Entity Relationship Diagrams
	* [x] Gantt
	* [x] Graphs
	* [x] Pie Charts
	* [x] Sequence Diagrams
	* [x] State Diagrams
	* [x] User Journey Diagrams
* Basic Markdown snippets
	* [x] Code Blocks
	* [x] LaTeX Blocks
	* [x] Tables
		* [x] Manipulating columns
		* [x] Initial generation
* [x] Links to helpful documentation from `:help`.

## Demo

This is a demo of most of the features. `TableMode` can do more than is shown, and there are more ways to access these features than through `:execute`-ing commands. Read the [docs](./doc/typora.txt) for more information.

![Demo](./media/2020_10_02.11_44_05.gif "Demo")

* The theme in the demo is [nvim-highlite](https://github.com/Iron-E/nvim-highlite).

# Installation & Requirements

Requires the following:

* Neovim 0.5+
* [Typora](https://typora.io)
* [nvim-libmodal](https://github.com/Iron-E/nvim-libmodal)
	* Snippet functionality with `:TyporaMode`.
	* Table manipulation with `:TableMode`.

__Optionally__ requires the following:

* [vim-markdown](https://github.com/plasticboy/vim-markdown/blob/master/ftplugin/markdown.vim)
	* Automatic table formatting.

You can install it like any other plugin. Here is an example which uses `vim-plug`:

```viml
Plug 'Iron-E/nvim-libmodal'
Plug 'Iron-E/nvim-typora'
Plug 'plasticboy/vim-markdown'
```
