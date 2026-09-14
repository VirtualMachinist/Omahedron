# Minimal hardware-configuration.nix for setup flake eval checks (not a real machine).
{ config, lib, pkgs, ... }:
{
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
