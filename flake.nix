{
  description = "Installer et configurer la police ObelixPro pour Rider sur NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.writeShellApplication {
      name = "install-obelixpro";
      runtimeInputs = [ pkgs.unzip pkgs.gnused pkgs.curl ];

      text = ''
        set -e
        echo "📁 Installation de la police ObelixPro..."

        mkdir -p "$HOME/.fonts"
        unzip -o "${self}/obelix-pro.zip" -d "$HOME/.local/share/fonts"

        echo "🔁 Mise à jour du cache de polices..."
        fc-cache -fv > /dev/null

        echo "🔍 Recherche du dossier de config JetBrains Rider..."
        CONFIG_DIR=$(find "$HOME/.config/JetBrains" -maxdepth 1 -type d -name "Rider*" | sort -r | head -n1)/options

        if [ ! -d "$CONFIG_DIR" ]; then
          echo "❌ Dossier de configuration Rider introuvable."
          exit 1
        fi

        echo "✏️ Modification des fichiers XML..."
        for FILE in editor.xml editor-font.xml ui.lnf.xml; do
          TARGET="$CONFIG_DIR/$FILE"
          if [ -f "$TARGET" ]; then
            sed -i "s/\(<option name=\"\\(FONT_FACE\\|EDITOR_FONT_NAME\\|FONT_NAME\\)\" value=\"\)[^\"]*\(\"\/>\)/\1ObelixPro\3/g" "$TARGET"
          fi
        done

        chmod -R u+rwX,go+rX "$HOME/.fonts"
        echo "✅ Police ObelixPro installée et configurée pour JetBrains Rider !"
        echo "🧠 Redémarre Rider pour voir les changements."
      '';
    };

    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/install-obelixpro";
    };
  };
}
