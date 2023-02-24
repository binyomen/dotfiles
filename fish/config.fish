#!/usr/bin/env fish

if not contains ~/bin $PATH
    set -xa PATH ~/bin
end

if test -d ~/.linuxbrew
    eval (~/.linuxbrew/bin/brew shellenv)
end
if test -d /home/linuxbrew/.linuxbrew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

if test -d ~/.cargo/bin
    set -xa PATH ~/.cargo/bin
end

set -x EDITOR nvim

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showuntrackedfiles 1

alias icat='kitty +kitten icat'
