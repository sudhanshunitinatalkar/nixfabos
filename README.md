# nixfabos
Nix Based Fabricaction Operating System (currently focusing on 3d pritners, progressing with CNC and so on....))

## command to print file content of this project

```bash
find . -type f -not -path '*/\.*' -not -name 'flake.lock' -not -iname 'LICENSE*' -print0 \
  | while IFS= read -r -d '' file; do
      echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "┃  $file"
      echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      cat "$file"
      echo ""
      echo ""
    done
```


nix build .#nixosConfigurations.nixosfab.config.system.build.sdImage
