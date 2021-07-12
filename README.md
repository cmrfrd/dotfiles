# dotfiles

My one stop shop for setting up my dev environment

## Non NixOS

If the system you are running on is not nixos, run the following commands to clone
the repository to the local dotfiles dir and do a basic setup.

**Note:** Ensure `git` and `make` are installed

``` shell
git clone git@github.com:cmrfrd/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make update nix
```

## Installing NixOS

If this dotfiles is intended to be installed on a NixOS system, proceed with the following steps.

## Boot to live CD of NixOS installer

Check the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-obtaining) for how to download
and setup a usb installer for NixOS. Make sure you are connected to the internet!

## Setup small `nix-env` shell to further setup the environment

```
nix-env -iA nixos.pkgs.gitAndTools.gitFull nixos.pkgs.gnumake
```

## Download `dotfiles` repo

```
USER_HOME=/home/cmrfrd
git clone git@github.com:cmrfrd/dotfiles.git $USER_HOME/.dotfiles
cd $USER_HOME/.dotfiles
```

## Creating a new machine

If you are creating a new machine, use `nixos-generate-config` to create new basic
template under the `machines` directory.

```bash
read -p "Name of machine: " MACHINE_NAME
mkdir -p $USER_HOME/.dotfiles/machines/$MACHINE_NAME
nixos-generate-config --root $USER_HOME/.dotfiles/machines --dir /$MACHINE_NAME
```

To ensure we are sourcing packages from the right places, update the nix channels
to something like this (depending how unstable you want it to be)

```bash
home-manager https://github.com/nix-community/home-manager/archive/master.tar.gz
nixos-unstable https://nixos.org/channels/nixos-unstable
nixpkgs https://nixos.org/channels/nixpkgs-unstable
```

Now go configure the generated `configuration.nix` with the basic changes needed.

After you are ready to apply your changes, create a symlink to your desired machine
for `nixos-rebuild` and apply the new configuration.

```
ln -s $USER_HOME/.dotfiles/machines/$MACHINE_NAME/* /etc/nixos/
sudo nixos-rebuild switch
```

After applying the new configuration make sure you log
in as root, change the pw of the user, logout, then log
in as the user.
