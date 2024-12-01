{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "weck";

  imports = [
    ../common/profiles/laptop.nix
    ./hardware.nix
  ];

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "gnome";
      user = "woze";
    };
    devices.steamdeck.enable = true;
    decky-loader.enable = true;
  };

  hardware.cpu.amd.updateMicrocode = true;

  # nix cross build support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux i686-linux
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };
  hardware.uinput.enable = true;
  hardware.opentabletdriver.enable = true;

  networking.firewall.allowedTCPPorts = [ 29999 ];
  networking.firewall.allowedUDPPorts = [ 29999 ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];

  # ssh
  services.openssh.enable = true;
  services.openssh.startWhenNeeded = true;

  environment.systemPackages = with pkgs; [
    waypipe
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.touch-x
    gnomeExtensions.paperwm
    (gnomeExtensions.gjs-osk.overrideAttrs (oldAttrs: {
      postBuild = ''
        mkdir keycodes
        pushd keycodes
        tar -Jxf ../keycodes.tar.xz -C ./
        popd
      '';
    }))
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.auto-activities
    gnomeExtensions.just-perfection
    gnome-terminal
    extest
    (writeShellScriptBin "sd-desk" ''
      #!/usr/bin/env bash
      LD_PRELOAD=${pkgsi686Linux.extest}/lib/libextest.so steam -silent
    '')
    ss.xencelabs
  ];

  programs.fuse.userAllowOther = true;
  programs.steam.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
  };
  services.gnome.core-utilities.enable = false;

  services.udev.extraRules = ''
    # Read write access for all USB3Vision devices
    SUBSYSTEM=="usb", ATTRS{bDeviceClass}=="ef", ATTRS{bDeviceSubClass}=="02", ATTRS{bDeviceProtocol}=="01", ENV{ID_USB_INTERFACES}=="*:ef0500:*", MODE="0666"
  '';
  services.udev.packages = with pkgs; [
    gnome-settings-daemon
    ss.xencelabs
  ];

  services.tlp.enable = false;

  services.xserver.videoDrivers = [
    "amdgpu"
    "modesetting"
  ];

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };

  users.users.woze.extraGroups = [
    "docker"
    "libvirtd"
    "video"
    "render"
    "vboxusers"
    "libvirt"
    "corectrl"
    "adbusers"
    "wireshark"
    "kvm"
  ];
  home-manager.users.woze = ./home.nix;

  system.stateVersion = "24.05";
}
