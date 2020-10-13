source ~/.dotfiles/config/fish/aliases.sh

if command -v exa > /dev/null
	abbr -a ls 'exa'
	abbr -a l 'exa -lah --git'
	abbr -a ll 'exa -l'
	abbr -a lll 'exa -la'
else
	abbr -a l 'ls -lFh'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
  alias la='ls -lAFh'
  alias lr='ls -tRFh'
end

if command -v docker-compose > /dev/null
	abbr -a dc 'docker-compose'
end

if test -f ~/.nix-profile/share/autojump/autojump.fish;
    source ~/.nix-profile/share/autojump/autojump.fish
end
