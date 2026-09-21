{
  hedron,
  hedron-light,
}:
{
  config,
  lib,
  ...
}:
let
  cfg = config.omahedron.themes;
in
{
  options.omahedron.themes.enable = lib.mkEnableOption ''
    Symlink Hedron and Hedron Light into ~/.config/omarchy/themes.
    Stock Omarchy then loads them with `omarchy theme set`.
  '';

  config = lib.mkIf cfg.enable {
    xdg.configFile."omarchy/themes/hedron".source = hedron;
    xdg.configFile."omarchy/themes/hedron-light".source = hedron-light;
  };
}
