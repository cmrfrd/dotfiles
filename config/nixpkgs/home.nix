{ config, pkgs, lib, ... }:

let user = builtins.getEnv "USER";
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
in rec {

  home.packages = [

    ## Browser
    pkgs.brave

    ## Bars
    pkgs.polybar

    ## font
    pkgs.font-awesome-ttf

    ## windowing
    pkgs.xsel
    pkgs.wmctrl
    pkgs.screen
    pkgs.xdotool

    ## shells
    pkgs.fish
    pkgs.bash

    ## cli/tools
    pkgs.jq
    pkgs.tree
    pkgs.git
    pkgs.gnumake
    pkgs.parallel
    pkgs.openssl
    pkgs.openssh
    pkgs.curl
    pkgs.feh
    pkgs.wordnet
    pkgs.shutter
    pkgs.plantuml
    pkgs.imagemagick
    pkgs.exa
    pkgs.autojump

    ## containers
    pkgs.docker
    pkgs.docker_compose

    ## pl
    pkgs.nodejs

    ## extra...
    pkgs.terminator
    pkgs.glib-networking
    pkgs.nodePackages.eslint
    pkgs.nodePackages.jsonlint
    pkgs.nodePackages.prettier
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.typescript
    pkgs.nodePackages.vscode-html-languageserver-bin
    pkgs.nodePackages.vscode-css-languageserver-bin
    pkgs.nodePackages.node2nix
    pkgs.haskellPackages.hledger

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
    profiles = {
      default = {
        isDefault = true;
        settings = {
          "browser.display.background_color" = "#bdbdbd";
          "devtools.theme" = "dark";
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "general.smoothScroll" = false;
          "layout.css.devPixelsPerPx" = "1";
          "network.IDN_show_punycode" = true;
          "network.allow-experiments" = false;
          "widget.content.gtk-theme-override" = "Adwaita:light";
          "accessibility.typeaheadfind.enablesound" = false;
        };
      };
    };
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
