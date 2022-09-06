{ config, pkgs, lib, ... }:

let
  username = "cmrfrd";

  emacs_overlay = import (builtins.fetchTarball {
    # url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    url = https://github.com/nix-community/emacs-overlay/archive/57378ea2f62e9f450f420dc9d01cc06e0d3dd15e.tar.gz;
  });
  emac = import <nixpkgs> { overlays = [ emacs_overlay ]; };

in {
  imports =
    [
      ./hardware-configuration.nix

      ../../home-manager/nixos
    ];

  nix.autoOptimiseStore = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # https://github.com/NixOS/nixpkgs/issues/98766
  boot.kernelModules = [ "br_netfilter" "ip_conntrack" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "overlay" "fuse" "coretemp" "tun" "nfs" ];
  boot.kernelParams = [ ''cgroup_memory=1'' ''cgroup_enable=memory'' ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.plymouth.enable = false;

  powerManagement.enable = true;

  networking.hostName = "queen";
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

  programs.mtr.enable = true;
  programs.light.enable = true;

  programs.fuse = {
    userAllowOther = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-bluetooth-policy auto_switch=2
    '';
  };

  # ooooweeee dynamic dns is awesome
  # services.ddclient = {
  #   enable = true;
  #   extraConfig = (builtins.readFile ~/.dotfiles/creds/ddclient.conf);
  # };

  # Logind don't close on lid switch
  # services.logind.lidSwitch = "ignore";
  services.logind.lidSwitch = "suspend";

  services.k3s = {
    enable = true;
    docker = true;
    extraFlags = "--no-deploy local-storage --no-deploy traefik --no-deploy servicelb --no-deploy metrics-server";
  };
  systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];
  systemd.services.k3s.serviceConfig.KillMode = lib.mkForce "control-group";
  # systemd.services.k3s.serviceConfig = {
  #   ExecStartPre = "-/sbin/modprobe br_netfilter overlay";
  # };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i cni+ -j ACCEPT
  '';


  # Base desktop manager, not default
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    updateDbusEnvironment = true;
    libinput.enable = true;
    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = true;
        thunarPlugins = with pkgs; [
          xfce.thunar-archive-plugin
          xfce.thunar_volman
        ];
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
      lightdm = {
        enable = true;
      };
    };
  };


  # systemd.services.crio = {
  #   environment = {
  #     _CRIO_ROOTLESS = "1";
  #     CONTAINER_ROOT = "/home/${username}/.local/share/containers/storage/";
  #   };
  #   serviceConfig = {
  #     ExecStartPost = "/bin/sh -c \"chmod 0775 /var/run/crio/crio.sock && chgrp users /var/run/crio/crio.sock\" && chown cmrfrd /home/${username}/.local/share/containers/storage/overlay/l/";
  #   };
  # };
  virtualisation = {
    docker = {
      enable = true;
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
    # cri-o = {
    #   enable = true;
    # };
  };

  environment.systemPackages = with pkgs; [
    ((emacsPackagesNgGen emac.emacsGcc).emacsWithPackages (epkgs: [
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

  system.stateVersion = "21.11";
  system.autoUpgrade.enable = false;
}
