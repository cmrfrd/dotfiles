CURL?=$(which curl)

.PHONY: all

all:
	$(MAKE) zsh
	$(MAKE) update

update:
	./scripts/bootstrap

zsh:
	cd && $(CURL) -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash

emacs-build:
	bash -c "\
		git clone -b master git://git.sv.gnu.org/emacs.git /tmp/emacs; \
		cd /tmp/emacs/; \
		git checkout emacs-25.3; \
		sudo apt install --no-install-recommends -y texinfo; \
		sudo apt install -y libXpm libgif libgtk-3-dev libxpm-dev libjpeg8-dev libgif-dev libtiff5-dev libtinfo-dev librsvg2-dev libmagickwand-dev libacl1-dev libgnutls-dev; \
		./configure --with-xpm=no --with-gif=no; \
		make check; \
		sudo make install"
