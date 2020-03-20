{ config, pkgs, lib, ... }:

let user = builtins.getEnv "USER";
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
in rec {

  home.packages = [
    pkgs.nodejs
    pkgs.xsel
    pkgs.wmctrl
    pkgs.fish
    pkgs.tree
    pkgs.bash
    pkgs.screen
    pkgs.git
    pkgs.gnumake
    pkgs.openssl
    pkgs.openssh
    pkgs.curl
    pkgs.feh
    pkgs.terminator
    pkgs.wordnet
    pkgs.glib-networking
    pkgs.plantuml
  ];

  gtk = {
    enable = true;
    font = {
      name = "Noto Sans 10";
      package = pkgs.noto-fonts;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adapta-Nokto-Eta";
      package = pkgs.adapta-gtk-theme;
    };
  };

  programs.emacs = {
    enable = true;
    package = (pkgs.emacs.override {
      withX = true;
      withGTK3 = true;
      withGTK2 = false;
      withXwidgets = true;
    });
  };

  services.emacs = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    extensions = with nur.repos.rycee.firefox-addons; [
      https-everywhere
      ghostery
      react-devtools
      refined-github
      umatrix
    ];
  };

  programs.fish = {
    enable = true;
    promptInit = builtins.readFile "${builtins.getEnv "HOME"}/.dotfiles/config/fish/rc.fish";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    initExtra = ''
    source ~/.config/fish/aliases.fish
    '';
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "daveverwer";
  };

  programs.feh = {
    enable = true;
  };

  programs.home-manager = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
