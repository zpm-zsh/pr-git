# Plugin for ZSH who display Git info

Plugin creates a global variable with `git` status information that can be displayed in prompts.

### Example

```sh
PROMPT='$pr_git ...REST OF PROMPT'
```

#### Screenshot
![Screenshot](./image.png)

This plugin made to be fast. It runs in background and update information only if need.

## Installation

### This plugin depends on [zsh-helpres](https://github.com/zpm-zsh/helpers)

If you don't use [zpm](https://github.com/zpm-zsh/zpm), install it manually and activate it before this plugin. 
If you use zpm you don’t need to do anything

### If you use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

* Clone this repository into `~/.oh-my-zsh/custom/plugins`
```sh
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zpm-zsh/pr-git
```
* After that, add `pr-git` to your oh-my-zsh plugins array.

### If you use [Zgen](https://github.com/tarjoilija/zgen)

1. Add `zgen load zpm-zsh/pr-git` to your `.zshrc` with your other plugin
2. run `zgen save`

### If you use my [ZPM](https://github.com/zpm-zsh/zpm)

* Add `zpm load zpm-zsh/pr-git` into your `.zshrc`