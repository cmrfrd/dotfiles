{ config, pkgs, ... }:

let user = builtins.getEnv "USER";
in rec {

  home.packages = [
    pkgs.xsel
    pkgs.wmctrl
    pkgs.fish
    pkgs.tree
    pkgs.bash
    pkgs.screen
    pkgs.git
    pkgs.gnumake
    pkgs.openssl
    pkgs.curl
  ];

  programs.emacs = {
    enable = true;
    package = (pkgs.emacs.override {
      withGTK3 = true;
      withGTK2 = false;
      withXwidgets = true;
    });
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

  programs.home-manager = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
