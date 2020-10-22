{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim firefox
  ];

  programs.mtr.enable = true;

  networking.firewall.enable = false;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Base desktop manager, not default
  services.xserver = {
    libinput.enable = true;
    desktopManager = {
	xterm.enable = false;
        xfce.enable = true;
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
  };

  system.stateVersion = "20.03"; # Did you read the comment?

}

