# Create a new directory and enter it
function mkd
	mkdir -p "$argv" && cd "$_";
end

function log
  script -q $LOG_FILE -c $argv[1];
end

function rand
  head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13
end

function cleanlog
  sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
end

function not3
    set s (echo $argv | head -c 1)
    set m (echo $argv | cut -c2- | wc -c)
    set e (echo $argv | tail -c 2)
    echo $s$m$e
end

function stc
    screen -t (not3 $argv) fish -c {$argv}; screen -X other
end

# # Start an HTTP server from a directory, optionally specifying the port
# function server() {
# 	local port="${1:-8000}";
# 	sleep 1 && open "http://localhost:${port}/" &
# 	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
# 	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
# 	sudo docker run -v $(pwd):/var/www:ro -p $port:8080 trinitronx/python-simplehttpserver

# }

# # Compare original and gzipped file size
# function gz() {
# 	local origsize=$(wc -c < "$1");
# 	local gzipsize=$(gzip -c "$1" | wc -c);
# 	local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l);
# 	printf "orig: %d bytes\n" "$origsize";
# 	printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
# }

function bw_session;
    if not test -n "$BW_SESSION"
        set -g -x BW_SESSION (bw unlock --raw)
    end
end

function bw_get_note;
    set search "$argv[1]"
    # test -z "$search"; and set search "\$\$\$"
    bw list items --session $BW_SESSION --search "$search" | jq -r ".[] | .notes | select (.!=null)"
end

function vterm_printf;
    if [ -n "$TMUX" ]
        # tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
    else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$argv"
    else
        printf "\e]%s\e\\" "$argv"
    end
end

## Add user to docker group
# if echo (groups $USER) | grep -v -w -q "docker";
#     echo 'Adding current user $USER to docker group ... ';
#     sudo usermod -aG docker $USER;
# end

## Chmod brave exec
if test -e "~/.nix-profile/opt/brave.com/brave/chrome-sandbox";
    if [ (stat -c '%a' "~/.nix-profile/opt/brave.com/brave/chrome-sandbox") -eq "4755" ];
        sudo chown root ~/.nix-profile/opt/brave.com/brave/chrome-sandbox
        sudo chmod 4755 ~/.nix-profile/opt/brave.com/brave/chrome-sandbox
    end
end
