# Hyprland v0.56.2 CMakeLists.txt requires glaze 7...<8 and otherwise
# FetchContent-clones v7.2.0 during configure. Its pinned nixpkgs provides
# Glaze 8, so supply the requested source as a fixed-output Nix dependency.
# Keep the upstream compiler/package set and its SSL/interop settings.
{
  upstreamHyprland,
  glaze,
  fetchFromGitHub,
}:
upstreamHyprland.override {
  glaze-hyprland =
    (glaze.override {
      enableSSL = false;
      enableInterop = false;
    }).overrideAttrs
      (
        finalAttrs: _previousAttrs: {
          version = "7.2.0";
          src = fetchFromGitHub {
            owner = "stephenberry";
            repo = "glaze";
            tag = "v${finalAttrs.version}";
            hash = "sha256-f3NVRi3SXKo42hn0WCw7JsOK3EkdOVJIcuzhPorKjFY=";
          };
        }
      );
}
