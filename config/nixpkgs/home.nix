{ config, pkgs, ... }:

let

  user = builtins.getEnv "USER";

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };

  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  moz = import <nixpkgs> { overlays = [ moz_overlay ]; };

in rec {

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
  #   }))
  # ];

  home.sessionVariables = {
    EDITOR = "emacs";
    XLIB_SKIP_ARGB_VISUALS = 1;
  };

  home.packages = with pkgs; [

    ## Apps
    brave
    bitwarden
    protonmail-bridge
    thunderbird
    pinentry
    sqlite

    ## Bars
    polybar

    ## Fonts / Locales
    font-awesome-ttf
    fontconfig
    dejavu_fonts
    source-code-pro
    source-sans-pro
    source-serif-pro
    glibcLocales

    ## windowing
    xsel
    wmctrl
    screen
    xdotool

    ## shells
    fish
    bash

    ## cli/tools
    ## Git
    git
    tig
    gitAndTools.gh
    gitAndTools.git-sync
    git-crypt
    keychain
    ## JSON
    jq

    arandr
    ## FS
    exa
    ack
    fd
    inotify-tools
    entr
    tree
    autojump
    pandoc
    rclone
    ## Color
    highlight
    ## Build
    gcc
    glibc
    cmake
    gnumake
    parallel
    ## Sec
    gnupg
    openssl
    ## Net
    openssh
    curl
    bind
    wireshark
    ddclient
    ## Img
    feh
    shutter
    imagemagick
    ## Lang
    ispell
    wordnet
    ## Desktop
    libnotify
    notify-desktop
    dunst
    light
    ## Torrent
    deluge
    ## Misc
    plantuml
    graphviz
    libtool
    libvterm-neovim
    neofetch
    licensor
    at
    direnv
    graph-easy

    ## containers
    docker_compose
    kubectl

    ## js
    nodejs
    yarn

    ## java
    openjdk

    ## rust
    wasm-pack
    cargo-web
    (moz.latest.rustChannels.nightly.rust.override {
      targets = ["wasm32-unknown-unknown"];
    })

    ## extra...
    terminator
    glib-networking
    nodePackages.eslint
    nodePackages.jsonlint
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.node2nix
    nodePackages.bitwarden-cli
    haskellPackages.hledger

    (makeDesktopItem {
      name = "org-protocol";
      exec = "emacsclient %u";
      comment = "Org Protocol";
      desktopName = "org-protocol";
      type = "Application";
      mimeType = "x-scheme-handler/org-protocol";
    })
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

  # # https://tecosaur.github.io/emacs-config/config.html
  # home.file.".local/share/applications/org-protocol.desktop".source = ../xorg/org-protocol.desktop ;
  # xdg = {
  #   enable = true;
  #   mimeApps = {
  #     enable = true;
  #     defaultApplications = {
  #       "x-scheme-handler/org-protocol" = [ "org-protocol.desktop" ];
  #     };
  #   };
  # };

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
      "kkkjlfejijcjgjllecmnejhogpbcigdc" # org capture
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

    settings = {
      global = {
        geometry = "500x5-30+50";
        transparency = 10;
        padding = 15;
        horizontal_padding = 17;
        word_wrap = true;
        follow = "keyboard";
      };
      shortcuts = {
        close = "ctrl+space";
      };
    };
  };

}
