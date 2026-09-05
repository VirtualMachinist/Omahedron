# Evaluate mappings against the same default module a consumer imports. JSON
# carries only booleans/names, never store references that would build the full
# desktop closure just to check attribute availability.
{
  pkgs,
  nixpkgs,
  self,
  system,
  omarchy-src,
}:
let
  inherit (pkgs) lib;
  ledger = builtins.fromJSON (builtins.readFile ../schema/packages.map.json);
  rows = ledger.packages ++ ledger.extra_packages;
  host = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.default
      {
        omarchy.enable = true;
        system.stateVersion = "26.05";
      }
    ];
  };
  packageName = pkg: builtins.unsafeDiscardStringContext (lib.getName pkg);
  defaultNames = map packageName (
    host.config.environment.systemPackages
    ++ host.config.fonts.packages
    ++ host.config.boot.plymouth.themePackages
  );
  probe = row: {
    name = row.upstream;
    value = {
      inherit (row) attr status;
    }
    // (
      let
        packages = if row.status == "pkgs" then self.packages.${system} else host.pkgs;
        package = lib.attrByPath (lib.splitString "." row.attr) null packages;
        result = builtins.tryEval (
          assert lib.isDerivation package;
          builtins.seq package.drvPath {
            valid = true;
            default = builtins.elem (packageName package) defaultNames;
          }
        );
      in
      if result.success then result.value else { valid = false; }
    );
  };
  options = lib.unique (lib.concatMap (row: row.options or [ ]) rows);
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  lockedInput = lock.nodes.${lock.nodes.root.inputs.omarchy-src};
  evidence = pkgs.writeText "ledger-evidence.json" (
    builtins.toJSON {
      pin = lockedInput.original.ref;
      upstream_rev = omarchy-src.rev;
      runtime = import ../pkgs/omarchy-runtime-manifest.nix;
      local_packages = builtins.attrNames self.packages.${system};
      packages = builtins.listToAttrs (
        map probe (
          builtins.filter (
            row:
            builtins.elem row.status [
              "pkgs"
              "nixpkgs"
            ]
          ) rows
        )
      );
      options = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = lib.isOption (lib.attrByPath (lib.splitString "." name) null host.options);
        }) options
      );
    }
  );
  python = pkgs.python3.withPackages (ps: [ ps.jsonschema ]);
in
pkgs.runCommand "omarchy-ledgers"
  {
    nativeBuildInputs = [ python ];
    # Explicit module path also works when an emulated interpreter resolves its
    # executable to the underlying Python rather than the withPackages env.
    PYTHONPATH = "${python}/${pkgs.python3.sitePackages}";
  }
  ''
    ${python}/bin/python3 ${./.}/ledgers.py \
      --repo ${../.} \
      --upstream ${omarchy-src} \
      --packaged ${self.packages.${system}.omarchy}/share/omarchy \
      --evidence ${evidence}
    ${python}/bin/python3 ${./.}/test_ledgers.py \
      --repo ${../.} \
      --upstream ${omarchy-src} \
      --packaged ${self.packages.${system}.omarchy}/share/omarchy \
      --evidence ${evidence}
    touch "$out"
  ''
