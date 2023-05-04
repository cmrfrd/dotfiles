{ config, pkgs, lib, ... }:

let

    username = "cmrfrd";

    emacs_overlay = import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      # url = https://github.com/nix-community/emacs-overlay/archive/57378ea2f62e9f450f420dc9d01cc06e0d3dd15e.tar.gz;
    });
    emac = import <nixpkgs> { overlays = [ emacs_overlay ]; };

    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
    '';

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

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../home-manager/nixos
    ];

  nix.extraOptions = ''experimental-features = nix-command flakes'';
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "spam";
  networking.networkmanager.enable = true;
  networking.proxy.noProxy = "127.0.0.1,localhost";
  networking.firewall.enable = true;
  networking.extraHosts =
    ''
    127.0.0.1 *.localhost
    127.0.0.1 home
  '';

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  # Base desktop manager, not default
  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;
    libinput.enable = true;
    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = true;
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
      lightdm = {
          enable = true;
      };
    };
  };

  boot.plymouth.enable = false;
  boot.blacklistedKernelModules = [ "nouveau" "intel" ];
  boot.kernelParams = [ "nouveau.modeset=0" ];
  boot.kernelPackages = pkgs.linuxPackages_5_19;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.nvidiaPersistenced = false;
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  programs.thunar.plugins = with pkgs;[
    xfce.thunar-archive-plugin
    xfce.thunar-volman
  ];
  programs.mtr.enable = true;
  programs.light.enable = true;

  programs.fuse = {
    userAllowOther = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-bluetooth-policy auto_switch=2
    '';
  };

  # Logind don't close on lid switch
  # services.logind.lidSwitch = "ignore";
  services.logind.lidSwitch = "suspend";

  services.flatpak.enable = true;
  services.avahi = {
    nssmdns = true;
    enable = true;
    publish = {
      enable = true;
      userServices = true;
      domain = true;
    };
  };

  #services.k3s = {
  #  enable = true;
  #  docker = true;
  #  extraFlags = "--no-deploy local-storage --no-deploy traefik --no-deploy servicelb --no-deploy metrics-server";
  #};
  #systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];
  #systemd.services.k3s.serviceConfig.KillMode = lib.mkForce "control-group";
  # systemd.services.k3s.serviceConfig = {
  #   ExecStartPre = "-/sbin/modprobe br_netfilter overlay";
  # };
  #networking.firewall.extraCommands = ''
  #  iptables -A INPUT -i cni+ -j ACCEPT
  #'';

  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };
    podman = {
      enable = true;
    };
    containers = {
      enable = true;
    };
    libvirtd = {
      enable = true;
    };
    cri-o = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nvidia-offload
    ((emacsPackagesFor emac.emacsNativeComp).emacsWithPackages (epkgs: [
      epkgs.vterm
      epkgs.helm
    ]))
    pkgs.fuse3
  ];

  # Default user for machines
  users.extraUsers.root.initialHashedPassword = "";
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [
	    "wheel"
      "libvirtd"
	    "networkmanager"
	    "audio"
      "video"
	    "tty"
	    "dialout"
      "docker"
      "shadow"
    ];
    shell = pkgs.fish;
  };
  home-manager.users."${username}" = { pkgs, ... }: {
    imports = [ ../../config/nixpkgs/home.nix ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
