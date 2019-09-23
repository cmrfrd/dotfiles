.PHONY: all zsh update

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
	bash -c "bash <(curl https://nixos.org/nix/install)"

nix-update:
	nix-channel --add https://github.com/rycee/home-manager/archive/release-19.03.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	home-manager build

nix-update-shell:
	sudo bash -c "echo '$$HOME/.nix-profile/bin/zsh' >> /etc/shells"
	chsh -s $$HOME/.nix-profile/bin/zsh

nix: nix-setup nix-install nix-update

nix-clean:
	sudo rm -rf /etc/nix /nix /root/.nix-profile /root/.nix-defexpr /root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
