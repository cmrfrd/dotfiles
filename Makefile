.PHONY: all zsh update

MY_USER = $(eval MY_USER := $(shell whoami))

BUILD_PATH = $(eval BUILD_PATH :=			\
		$(shell NIX_PATH=$(NIXPATH)				\
			    nix-build $(BUILD_ARGS)))$(BUILD_PATH)

all:
	$(MAKE) update

update:
	./scripts/bootstrap


nix-setup:
	sudo bash -c "                                   \
		mkdir -p /nix /etc/nix;                        \
		chmod a+rwx /nix;                              \
		echo 'sandbox = false' > /etc/nix/nix.conf;"


nix-install:
  sudo mkdir /nix \
	sudo chmod $(MY_USER) -R /nix \
	bash -c "\
	  bash <(curl https://nixos.org/nix/install)\
    && . ~/.nix-profile/etc/profile.d/nix.sh"

# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-update:
	bash -c "\
		export NIX_PATH=$$HOME/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels ;\
    export NIXPKGS_ALLOW_BROKEN=1 ;\
    export NIXPKGS_ALLOW_UNFREE=1 ;\
		nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager \
		&& nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
		&& nix-channel --update \
		&& nix-shell '<home-manager>' -A install \
		&& home-manager build"

nix-update-shell:
	sudo bash -c "echo '$$HOME/.nix-profile/bin/fish' >> /etc/shells"
	chsh -s /home/$(MY_USER)/.nix-profile/bin/fish

nix: nix-setup nix-install nix-update nix-update-shell

nix-clean:
	sudo rm -rf /etc/nix /nix /root/.nix-profile /root/.nix-defexpr /root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels


# link machine
# sudo ln -s ~/.dotfiles/machines/<name>/* /etc/nixos/
