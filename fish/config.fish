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

if test -d /usr/local/go/bin
    set -xa PATH /usr/local/go/bin
end

set -x EDITOR nvim
set -x VISUAL nvim

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showuntrackedfiles 1

alias icat='kitty +kitten icat'

# Based on https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_night.fish
set -l theme_foreground c0caf5
set -l theme_selection 33467c
set -l theme_comment 565f89
set -l theme_red f7768e
set -l theme_orange ff9e64
set -l theme_yellow e0af68
set -l theme_green 9ece6a
set -l theme_purple 9d7cd8
set -l theme_cyan 7dcfff
set -l theme_pink bb9af7
set -g fish_color_normal $theme_foreground
set -g fish_color_command $theme_purple
set -g fish_color_keyword $theme_pink
set -g fish_color_quote $theme_yellow
set -g fish_color_redirection $theme_foreground
set -g fish_color_end $theme_orange
set -g fish_color_error $theme_red
set -g fish_color_param $theme_green
set -g fish_color_comment $theme_comment
set -g fish_color_selection --background=$theme_selection
set -g fish_color_search_match --background=$theme_selection
set -g fish_color_operator $theme_green
set -g fish_color_escape $theme_pink
set -g fish_color_autosuggestion $theme_comment
set -g fish_pager_color_progress $theme_comment
set -g fish_pager_color_prefix $theme_cyan
set -g fish_pager_color_completion $theme_foreground
set -g fish_pager_color_description $theme_comment
set -g fish_pager_color_selected_background --background=$theme_selection
set -g fish_color_status $theme_red
set -g fish_color_cwd $theme_cyan
set -g fish_color_cwd_root $theme_red
set -g fish_color_host $theme_foreground
set -g fish_color_host_remote $theme_yellow
set -g fish_color_user $theme_cyan
