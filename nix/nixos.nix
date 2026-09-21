{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.omahedron.themes.enable = lib.mkEnableOption ''
    Put the Hedron theme package on PATH via the system profile.
    This does not install a desktop. Stock Omarchy reads themes from
    ~/.config/omarchy/themes; use the Home Manager module or copy the
    theme directories by hand.
  '';

  config = lib.mkIf config.omahedron.themes.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./themes.nix {
        hedron = ../themes/hedron;
        hedron-light = ../themes/hedron-light;
      })
    ];
  };
}
