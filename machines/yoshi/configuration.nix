{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../home-manager/nixos
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.enable = true;

  networking.hostName = "yoshi";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlo1.useDHCP = true;
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  programs.mtr.enable = true;

  networking.firewall.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-bluetooth-policy auto_switch=2
    '';
  };

  # ddclient ooooweeee dynamic dns is awesome
  # services.ddclient = {
  #   enable = true;
  # };

  # cron is pretty useful
  services.cron.enable = true;

  # Base desktop manager, not default
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    layout = "us";
    libinput.enable = true;
    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
        thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ];
      };
      pantheon.enable = true;
    };
    windowManager = {
      exwm = {
        enable = true;
        enableDefaultConfig = false;
        extraPackages = epkgs: [
          epkgs.vterm
        ];
      };
    };
    displayManager = {
      sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
      defaultSession = "xfce+exwm";
    };
  };

  # Default user for machines
  users.users.cmrfrd = {
    isNormalUser = true;
    extraGroups = [
	    "wheel"
	    "networkmanager"
	    "audio"
	    "tty"
	    "dialout"
    ];
    shell = pkgs.fish;
  };
  home-manager.users.cmrfrd = { pkgs, ... }: {
    imports = [ ../../config/nixpkgs/home.nix ];
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ((emacsPackagesNgGen emacs27).emacsWithPackages (epkgs: [
      epkgs.vterm
      epkgs.helm
    ]))
  ];

  system.stateVersion = "20.09"; # Did you read the comment?

}
