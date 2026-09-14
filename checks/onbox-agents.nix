# oma-cli G5: omarchy.enable ships /etc/omahedron/AGENTS.md; disabled hosts do not;
# omarchy-debug points at it. Assertions are precomputed for plain shell.
{
  pkgs,
  nixpkgs,
  self,
  system,
}:
let
  inherit (pkgs) lib;
  exampleCfg = self.nixosConfigurations.example.config;
  disabledCfg =
    (self.nixosConfigurations.example.extendModules {
      modules = [
        {
          omarchy.enable = lib.mkForce false;
        }
      ];
    }).config;
  agentsEtc = exampleCfg.environment.etc."omahedron/AGENTS.md" or { };
  agentsText =
    if (agentsEtc.text or null) != null then
      agentsEtc.text
    else if agentsEtc.source or null != null then
      builtins.readFile agentsEtc.source
    else
      "";
  omarchyDebug = "${self.packages.${system}.omarchy}/share/omarchy/bin/omarchy-debug";
in
pkgs.runCommand "omarchy-onbox-agents-check"
  {
    ENABLED_HAS_ETC = lib.boolToString (
      exampleCfg.environment.etc ? "omahedron/AGENTS.md"
      && (agentsEtc.enable or true)
    );
    DISABLED_HAS_ETC = lib.boolToString (
      disabledCfg.environment.etc ? "omahedron/AGENTS.md"
    );
    HAS_AGENTS_EDIT_NIX = lib.boolToString (lib.hasInfix "agents edit Nix" agentsText);
    HAS_ETC_PATH = lib.boolToString (lib.hasInfix "/etc/omahedron/AGENTS.md" agentsText);
    HAS_OMARCHY_PATH = lib.boolToString (lib.hasInfix "$OMARCHY_PATH" agentsText);
    HAS_X86_64_LINUX = lib.boolToString (lib.hasInfix "x86_64-linux" agentsText);
  }
  ''
    set -euo pipefail
    fail() { echo "FAIL: $*" >&2; exit 1; }

    [ "$ENABLED_HAS_ETC" = true ] ||
      fail "example host must declare environment.etc.omahedron/AGENTS.md when omarchy.enable"
    [ "$DISABLED_HAS_ETC" = false ] ||
      fail "omarchy.enable = false must not declare /etc/omahedron/AGENTS.md"
    [ "$HAS_AGENTS_EDIT_NIX" = true ] ||
      fail "on-box AGENTS.md must contain the exact phrase: agents edit Nix"
    [ "$HAS_ETC_PATH" = true ] ||
      fail "on-box AGENTS.md must mention /etc/omahedron/AGENTS.md"
    [ "$HAS_OMARCHY_PATH" = true ] ||
      fail "on-box AGENTS.md must mention \$OMARCHY_PATH"
    [ "$HAS_X86_64_LINUX" = true ] ||
      fail "on-box AGENTS.md must mention x86_64-linux"
    grep -Fq '/etc/omahedron/AGENTS.md' ${omarchyDebug} ||
      fail "omarchy-debug does not point at /etc/omahedron/AGENTS.md"
    grep -Fq 'agents edit Nix' ${omarchyDebug} ||
      fail "omarchy-debug does not mention agents edit Nix"

    touch $out
  ''
