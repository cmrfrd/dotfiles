if test -f ~/.dotfiles/config/fish/completions/rclone.fish;
    rclone genautocomplete fish ~/.dotfiles/config/fish/completions/rclone.fish
    source ~/.dotfiles/config/fish/completions/rclone.fish
end
