.PHONY: all zsh update

all:
	$(MAKE) zsh
	$(MAKE) update

update:
	./scripts/bootstrap

zsh:
	curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o /tmp/install.sh && bash /tmp/install.sh

emacs-build:
	bash -c "\
		git clone -b master git://git.sv.gnu.org/emacs.git /tmp/emacs; \
		cd /tmp/emacs/; \
		git checkout emacs-25.3; \
		./configure --with-xpm=no --with-gif --with-jpg --with-png \
								--with-rsvg --with-tiff --with-xft --with-xpm \
							  --with-x-toolkit=gtk3 --with-gpm=no --with-dbus \
								--with-xwidgets; \
		make bootstrap; \
		make check; \
		make; \
		sudo make install"
