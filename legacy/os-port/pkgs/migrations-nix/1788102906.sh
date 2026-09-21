echo "Repair legacy XCompose include; drop Arch udev rule quarantine"

# NixOS adapter: keep the upstream ~/.XCompose repair that retargets the
# Omarchy 3 checkout compatibility include to $OMARCHY_PATH/default/xcompose.
# The rest of the upstream script (quarantine/remove vulnerable
# /etc/udev/rules.d/99-power-profile.rules and 99-wifi-powersave.rules) is
# dropped — NixOS udev rules are declarative, and those Arch-era RUN+= home
# paths were never shipped by the Omahedron module.

xcompose="$HOME/.XCompose"
packaged_xcompose="$OMARCHY_PATH/default/xcompose"
legacy_xcompose_pattern='^[[:space:]]*include[[:space:]]+"[^"]*/\.local/share/omarchy/default/xcompose"[[:space:]]*$'

# Omarchy 3 pointed the user's compose file through the checkout compatibility
# link. Preserve their own sequences while moving that include to the packaged
# tree. A failed live restart is harmless: the next graphical login reads the
# repaired file.
if [[ -f $xcompose ]] && grep -Eq "$legacy_xcompose_pattern" "$xcompose"; then
  xcompose_replacement=${packaged_xcompose//\\/\\\\}
  xcompose_replacement=${xcompose_replacement//&/\\&}
  xcompose_replacement=${xcompose_replacement//|/\\|}
  sed -i -E "s|^([[:space:]]*include[[:space:]]+\")[^\"]*/\\.local/share/omarchy/default/xcompose\"[[:space:]]*$|\\1$xcompose_replacement\"|" "$xcompose"
  omarchy-restart-xcompose >/dev/null 2>&1 || true
fi
