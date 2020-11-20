{ config, pkgs, lib, ... }:

let

  user = builtins.getEnv "USER";

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };

in rec {

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  home.sessionVariables = {
    EDITOR = "emacs";
    XLIB_SKIP_ARGB_VISUALS = 1;
  };

  home.packages = [

    ## Apps
    pkgs.brave
    pkgs.bitwarden
    pkgs.protonmail-bridge
    pkgs.thunderbird
    pkgs.pinentry

    ## Bars
    pkgs.polybar

    ## Fonts / Locales
    pkgs.font-awesome-ttf
    pkgs.fontconfig
    pkgs.dejavu_fonts
    pkgs.source-code-pro
    pkgs.source-sans-pro
    pkgs.source-serif-pro
    pkgs.glibcLocales

    ## windowing
    pkgs.xsel
    pkgs.wmctrl
    pkgs.screen
    pkgs.xdotool

    ## shells
    pkgs.fish
    pkgs.bash

    ## cli/tools
    ## Git
    pkgs.git
    pkgs.tig
    pkgs.gitAndTools.gh
    pkgs.git-crypt
    ## JSON
    pkgs.jq
    ## FS
    pkgs.exa
    pkgs.ack
    pkgs.fd
    pkgs.inotify-tools
    pkgs.tree
    pkgs.autojump
    pkgs.pandoc
    pkgs.rclone
    pkgs.archivemount
    ## Color
    pkgs.highlight
    ## Build
    pkgs.gcc
    pkgs.glibc
    pkgs.cmake
    pkgs.gnumake
    pkgs.parallel
    ## Sec
    pkgs.gnupg
    pkgs.openssl
    ## Net
    pkgs.openssh
    pkgs.curl
    pkgs.bind
    pkgs.wireshark
    pkgs.ddclient
    ## Img
    pkgs.feh
    pkgs.shutter
    pkgs.imagemagick
    ## Lang
    pkgs.ispell
    pkgs.wordnet
    ## Desktop
    pkgs.libnotify
    pkgs.notify-desktop
    pkgs.dunst
    pkgs.light
    ## Torrent
    pkgs.deluge
    ## Misc
    pkgs.plantuml
    pkgs.libtool
    pkgs.libvterm-neovim
    pkgs.neofetch
    pkgs.licensor
    pkgs.at
    pkgs.fcron

    ## containers
    pkgs.docker_compose
    pkgs.kubectl

    ## js
    pkgs.nodejs
    pkgs.yarn

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
    pkgs.nodePackages.bitwarden-cli
    pkgs.haskellPackages.hledger
  ];

  ## Not sure why but I need this
  ## github.com/nix-community/home-manager/issues/254
  manual.manpages.enable = false;

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
    extraPackages = epkgs: [
      epkgs.exwm
      epkgs.vterm
      epkgs.dictionary
    ];
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
    ];
  };

  # programs.firefox = {
  #   enable = true;
  #   extensions = with nur.repos.rycee.firefox-addons; [
  #     https-everywhere
  #     ghostery
  #     react-devtools
  #     refined-github
  #     umatrix
  #   ];
  #   profiles = {
  #     default = {
  #       isDefault = true;
  #       settings = {
  #         "browser.display.background_color" = "#bdbdbd";
  #         "devtools.theme" = "dark";
  #         "experiments.activeExperiment" = false;
  #         "experiments.enabled" = false;
  #         "experiments.supported" = false;
  #         "general.smoothScroll" = false;
  #         "layout.css.devPixelsPerPx" = "1";
  #         "network.IDN_show_punycode" = true;
  #         "network.allow-experiments" = false;
  #         "widget.content.gtk-theme-override" = "Adwaita:light";
  #         "accessibility.typeaheadfind.enablesound" = false;
  #       };
  #     };
  #   };
  # };

  programs.fish = {
    enable = true;
    promptInit = builtins.readFile "${builtins.getEnv "HOME"}/.dotfiles/config/fish/rc.fish";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    initExtra = ''
    export PATH=~/.dotfiles/scripts:$PATH
    source ~/.config/fish/aliases.sh
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

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "emacs";
    extraConfig = ''
    allow-emacs-pinentry
    allow-loopback-pinentry
    '';
  };

  services.dunst = {
    enable = true;
  };

}
