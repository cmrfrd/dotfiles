set -U fish_user_paths $HOME/bin /usr/local/bin $HOME/Public/scripts $HOME/.local/bin $HOME/.dotfiles/scripts $HOME/.nix-profile/bin/
set -U fish_greeting
set -U SHELL $HOME/.nix-profile/bin/fish
set -U EDITOR 'emacs'
set -U HISTSIZE '32768';
set -U HISTFILESIZE "{HISTSIZE}";
set -U HISTCONTROL 'ignoreboth';
set -U LESS_TERMCAP_md "{yellow}";
set -U LANG 'en_US.UTF-8';
set -U LC_ALL 'en_US.UTF-8';
set -U MANPATH "/usr/local/man:$MANPATH"
set -U LOG_DIR $HOME/.logs/(date +"%Y%m%d%H")
set -U LOG_FILE $LOG_DIR/$TERM-$STY-$WINDOW.log
set -U MINIKUBE_HOME /mnt/vm-storage/
set -U NIX_PATH $HOME/.nix-defexpr/channels $NIX_PATH

set -U LANG en_US.UTF-8
set -U LC_CTYPE "en_US.UTF-8"
set -U LC_NUMERIC "en_US.UTF-8"
set -U LC_TIME "en_US.UTF-8"
set -U LC_COLLATE "en_US.UTF-8"
set -U LC_MONETARY "en_US.UTF-8"
set -U LC_MESSAGES "en_US.UTF-8"
set -U LC_PAPER "en_US.UTF-8"
set -U LC_NAME "en_US.UTF-8"
set -U LC_ADDRESS "en_US.UTF-8"
set -U LC_TELEPHONE "en_US.UTF-8"
set -U LC_MEASUREMENT "en_US.UTF-8"
set -U LC_IDENTIFICATION "en_US.UTF-8"
set -U LC_ALL

set -U FONTCONFIG_PATH /etc/fonts
set -gx BROWSER firefox
