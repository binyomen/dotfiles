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

set -x EDITOR nvim

# I need to add spaces after the default prompt symbols so they don't look
# cramped in a monospace font.
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_char_cleanstate "✔ "
set -g __fish_git_prompt_char_conflictedstate "✖ "
set -g __fish_git_prompt_char_dirtystate "✚ "
set -g __fish_git_prompt_char_stagedstate "● "
set -g __fish_git_prompt_char_untrackedfiles "… "
set -g __fish_git_prompt_char_upstream_ahead "↑ "
set -g __fish_git_prompt_char_upstream_behind "↓ "
