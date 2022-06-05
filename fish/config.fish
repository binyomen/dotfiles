#!/usr/bin/env fish

if not contains ~/bin $PATH
    set -xa PATH ~/bin
end

set -x EDITOR nvim

set -g __fish_git_prompt_show_informative_status 1
