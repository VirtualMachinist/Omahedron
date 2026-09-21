{
  lib,
  runCommand,
  hedron,
  hedron-light,
}:
runCommand "omahedron-themes"
  {
    meta = {
      description = "Hedron and Hedron Light themes for stock Omarchy";
      homepage = "https://github.com/VirtualMachinist/Omahedron";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out/share/omarchy/themes"
    cp -R ${hedron} "$out/share/omarchy/themes/hedron"
    cp -R ${hedron-light} "$out/share/omarchy/themes/hedron-light"
  ''
