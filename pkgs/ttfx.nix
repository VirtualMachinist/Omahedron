# ttfx — upstream-owned Omarchy binary: terminal text effects as a single
# dependency-free Rust binary. Rust port of TerminalTextEffects (TTE) that
# renders byte-identical frames and starts in ~1ms instead of TTE's ~107ms
# Python startup. Powers the Omarchy screensaver (bin/omarchy-screensaver
# runs `ttfx -i <branding file>` and pgrep/pkill-matches the comm name).
# Vendored because nixpkgs does not ship a ttfx package (checked 2026-08-18
# against unstable).
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ttfx";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "omacom-io";
    repo = "ttfx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bwFjC6ZkZibkgXjoYVH2VuqqeXklGR9kmRl2fTitWBU=";
  };

  cargoHash = "sha256-DNrg12MNqBcQi6yvoJObM1gtE90iGBCxeQ3RwueYCE4=";

  meta = {
    description = "Terminal text effects as a single static binary (Rust TTE port, Omarchy screensaver)";
    homepage = "https://github.com/omacom-io/ttfx";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "ttfx";
  };
})
