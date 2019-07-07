.PHONY: zsh install
install:
	./scripts/bootstrap
zsh:
	cd
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
