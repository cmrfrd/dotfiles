{ config, pkgs, lib, ... }:

let

  user = builtins.getEnv "USER";

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };

  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  moz = import <nixpkgs> { overlays = [ moz_overlay ]; };

  emacs_overlay = import (builtins.fetchTarball {
    # url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    url = https://github.com/nix-community/emacs-overlay/archive/dd54cb4be116d3ca13f6e90a5bfb0e792b5133b5.tar.gz;
  });
  emac = import <nixpkgs> { overlays = [ emacs_overlay ]; };

  unstable = import <nixos-unstable> { config = { allowUnfree = true; allowBroken = true;}; };

  colors = {
    bg = "#282a36";
    bgalt = "#1E2029";
    base0 = "#1E2029";
    base1 = "#282a36";
    base2 = "#373844";
    base3 = "#44475a";
    base4 = "#565761";
    base5 = "#6272a4";
    base6 = "#b6b6b2";
    base7 = "#ccccc7";
    base8 = "#f8f8f2";
    fg = "#f8f8f2";
    fgalt = "#e2e2dc";
    grey = "#565761";
    red = "#ff5555";
    orange = "#ffb86c";
    green = "#50fa7b";
    teal = "#0189cc";
    yellow = "#f1fa8c";
    blue = "#61bfff";
    darkblue = "#0189cc";
    magenta = "#ff79c6";
    violet = "#bd93f9";
    cyan = "#8be9fd";
    darkcyan = "#8be9fd";
  };

in rec {

  home.sessionVariables = {
    EDITOR = "emacs";
    XLIB_SKIP_ARGB_VISUALS = 1;
    GOPATH = [ "${builtins.getEnv "HOME"}/go/" ];
  };

  home.packages = [

    ## Apps
    pkgs.brave
    pkgs.bitwarden
    pkgs.protonmail-bridge
    pkgs.thunderbird
    pkgs.sqlite
    pkgs.wget
    pkgs.terminator

    ## virt
    pkgs.vagrant
    pkgs.ignite

    ## Bars
    pkgs.polybar

    ## Fonts / Locales
    pkgs.font-awesome
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
    pkgs.xorg.xwininfo
    pkgs.xorg.xhost
    pkgs.arandr
    # pkgs.gtk3

    ## shells
    pkgs.fish
    pkgs.bash

    ## git
    pkgs.git
    pkgs.tig
    pkgs.gitAndTools.gh
    pkgs.gitAndTools.git-sync
    pkgs.git-crypt
    pkgs.keychain

    ## FS
    pkgs.exa
    pkgs.ack
    pkgs.fd
    pkgs.inotify-tools
    pkgs.entr
    pkgs.tree
    pkgs.autojump
    pkgs.pandoc
    pkgs.rclone
    ## Color
    pkgs.highlight
    ## Build
    pkgs.gcc
    pkgs.glibc
    pkgs.cmake
    pkgs.autoconf
    pkgs.gnumake
    pkgs.parallel
    ## Sec
    pkgs.gnupg
    pkgs.openssl
    ## Net
    pkgs.openssh
    pkgs.curl
    pkgs.bind
    # pkgs.wireshark
    # pkgs.ddclient
    ## Img
    pkgs.feh
    pkgs.shutter
    pkgs.imagemagick
    pkgs.ffmpeg-full
    ## Lang
    pkgs.ispell
    pkgs.languagetool
    pkgs.wordnet
    ## Desktop
    pkgs.libnotify
    pkgs.notify-desktop
    pkgs.dunst
    ## Torrent
    # pkgs.deluge
    ## Misc
    pkgs.jq
    pkgs.plantuml
    pkgs.graphviz
    pkgs.libtool
    pkgs.binutils
    # unstable.pkgs.libvterm-neovim
    pkgs.libvterm-neovim
    # pkgs.neofetch
    # pkgs.licensor
    # pkgs.at
    pkgs.direnv
    pkgs.graph-easy
    pkgs.mesa
    pkgs.envsubst
    pkgs.pinentry
    pkgs.texlive.combined.scheme-full

    ## infra
    pkgs.terraform

    ## containers
    pkgs.docker-compose
    pkgs.kubectl
    # pkgs.kube3d
    pkgs.k3s

    ## js
    pkgs.nodejs
    pkgs.yarn

    ## java
    pkgs.openjdk

    ## rust/wasm
    # pkgs.wasm-pack
    # pkgs.cargo-web
    # (moz.latest.rustChannels.nightly.rust.override {
    #   targets = ["wasm32-unknown-unknown"];
    # })

    ## extra...
    pkgs.vscode
    # pkgs.espeak
    pkgs.glib-networking
    pkgs.nodePackages.eslint
    pkgs.nodePackages.jsonlint
    pkgs.nodePackages.prettier
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.typescript
    pkgs.nodePackages.vscode-html-languageserver-bin
    pkgs.nodePackages.vscode-css-languageserver-bin
    pkgs.nodePackages.node2nix
    # pkgs.nodePackages.bitwarden-cli
    pkgs.nodePackages.mermaid-cli
    (pkgs.python3.withPackages(ps: with ps; [
      numpy
      jupyter
      matplotlib
      pandas
    ]))
    pkgs.godef
    pkgs.gotools
    pkgs.gopls

    # (pkgs.makeDesktopItem {
    #  name = "org-protocol";
    #  exec = "emacsclient %u";
    #  comment = "Org Protocol";
    #  desktopName = "org-protocol";
    #  type = "Application";
    #  mimeTypes = [ "x-scheme-handler/org-protocol" ];
    # })
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

  # https://tecosaur.github.io/emacs-config/config.html
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

  #[[ "$DESKTOP_SESSION" == *"exwm"* ]] &&
  #${emac.emacsGcc}/bin/emacs -f exwm-enable
  #      [[ "$DESKTOP_SESSION" == *"exwm"* ]] && exec dbus-launch --exit-with-session ${emac.emacsNativeComp}/bin/emacs --eval "(exwm-enable)"
  # exec ${emac.emacsNativeComp}/bin/emacs --eval "(exwm-enable)"

  # xsession = {
  #  enable = true;
  #  windowManager.command = ''
  #    ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER
  #  '';
  # };

  programs.emacs = {
    enable = true;
    package = (emac.emacsNativeComp.override {
      withX = true;
      withGTK3 = true;
      withGTK2 = false;
      withXwidgets = true;
      nativeComp = true;
    });
    extraPackages = epkgs: [
      epkgs.exwm
      epkgs.vterm
      epkgs.helm
      epkgs.dictionary
      epkgs.org
      epkgs.org-contrib
    ];
  };
  home.file.".emacs.d/load-path.el".source = pkgs.writeText "load-path.el" ''
    (let ((default-directory (file-name-as-directory
                           "${config.programs.emacs.finalPackage.deps}/share/emacs/site-lisp/"))
          (normal-top-level-add-subdirs-inode-list nil))
      (normal-top-level-add-subdirs-to-load-path))

  '';

  programs.chromium = {
    enable = true;
    extensions = [
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "kkkjlfejijcjgjllecmnejhogpbcigdc" # org capture
      "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # metamask
      "fhbohimaelbohpjbbldcngcnapndodjp" # binance wallet
      "dmkamcknogkgcdfhhbddcghachkejeap" # kepler (cosmos)
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

  # programs.fish = {
  #   enable = true;
  #   promptInit = builtins.readFile "${builtins.getEnv "HOME"}/.dotfiles/config/fish/rc.fish";
  # };

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
    extraConfig = ''
    Include ~/.ssh/config.d/*
    '';
  };

  programs.go = {
    enable = true;
    goPath = "${builtins.getEnv "HOME"}/go";
  };

  services.flameshot.enable = true;

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
    inactiveInterval = 20;
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

  home.stateVersion = "22.05";
}
