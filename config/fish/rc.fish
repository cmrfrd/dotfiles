if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

function dotreload
    source ~/.config/fish/exports.fish
    source ~/.config/fish/functions.fish
    source ~/.config/fish/aliases.fish
end
dotreload

## Make log directory
mkdir -p $LOG_DIR
touch $LOG_FILE

set LANG en_US.utf8
set LC_ALL

## Run screen if fish in emacs
if test (echo $TERMINFO | grep emacs | wc -l) -gt 0
    if not test -n "$STY"
        if test (echo $TERM | grep 'screen' | wc -l)
            exec screen -U -S (rand)
        end
   end
end
