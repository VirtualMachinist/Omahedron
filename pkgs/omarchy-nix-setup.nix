# Installer A backend: omarchy-nix-setup + omarchy-setup router binary.
{
  lib,
  stdenv,
  makeWrapper,
  jq,
  gum,
  util-linux,
  openssl,
  whois,
  omahedronFlakeUrl,
  hyprlandCache,
  promptsJson,
  templates,
}:

stdenv.mkDerivation {
  pname = "omarchy-nix-setup";
  version = "0.1";
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    substitute ${../modules/setup/omarchy-nix-setup.sh} $out/bin/omarchy-nix-setup \
      --replace-fail @@SETUP_TEMPLATE_DIR@@ ${templates} \
      --replace-fail @@SETUP_PROMPTS_FILE@@ ${promptsJson} \
      --replace-fail @@SETUP_OMAHEDRON_URL@@ ${omahedronFlakeUrl} \
      --replace-fail @@SETUP_HYPR_CACHE_URL@@ ${hyprlandCache.url} \
      --replace-fail @@SETUP_HYPR_CACHE_KEY@@ ${hyprlandCache.publicKey}
    chmod +x $out/bin/omarchy-nix-setup
    wrapProgram $out/bin/omarchy-nix-setup \
      --prefix PATH : ${lib.makeBinPath [ jq gum util-linux openssl whois ]}
  '';
}
