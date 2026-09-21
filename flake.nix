{
  description = "Omahedron: Hedron theme pack for stock Omarchy";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      each = f: nixpkgs.lib.genAttrs systems (system: f system);
      pkgsFor = system: import nixpkgs { inherit system; };
      themeArgs = {
        hedron = ./themes/hedron;
        hedron-light = ./themes/hedron-light;
      };
    in
    {
      overlays.default = final: _prev: {
        omahedron-themes = final.callPackage ./nix/themes.nix themeArgs;
      };

      packages = each (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = self.packages.${system}.omahedron-themes;
          omahedron-themes = pkgs.callPackage ./nix/themes.nix themeArgs;
        }
      );

      # Opt-in. Symlinks themes into ~/.config/omarchy/themes.
      homeManagerModules.default = import ./nix/hm.nix themeArgs;

      # Opt-in package install. The NixOS desktop port is archived.
      nixosModules.default = ./nix/nixos.nix;

      checks = each (
        system:
        let
          pkgs = pkgsFor system;
          themes = self.packages.${system}.omahedron-themes;
        in
        {
          theme-layout = pkgs.runCommand "omahedron-theme-layout" { } ''
            test -f ${themes}/share/omarchy/themes/hedron/colors.toml
            test -f ${themes}/share/omarchy/themes/hedron/keyboard.rgb
            test -f ${themes}/share/omarchy/themes/hedron/shell.lock.toml
            test -f ${themes}/share/omarchy/themes/hedron/backgrounds/hedron-platonic-altar.jpeg
            test -f ${themes}/share/omarchy/themes/hedron-light/light.mode
            test -f ${themes}/share/omarchy/themes/hedron-light/backgrounds/hedron-platonic-altar-light.jpeg
            bash ${./checks/theme-layout.sh} ${./.}
            touch "$out"
          '';
        }
      );

      formatter = each (system: (pkgsFor system).nixfmt-tree);
    };
}
