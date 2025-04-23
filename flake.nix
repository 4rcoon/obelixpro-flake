{
  description = "Installer et configurer la police ObelixPro pour Rider sur NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.stdenv.mkDerivation {
      name = "install-obelixpro";

      src = ./.;

      nativeBuildInputs = [ pkgs.unzip pkgs.gnused pkgs.curl ];

      installPhase = ''
        echo "📁 Installation de la police ObelixPro..."

        mkdir -p $HOME/.fonts
        unzip -o $src/obelix-pro.zip -d $HOME/.fonts

        echo "🔁 Mise à jour du cache de polices..."
        fc-cache -fv > /dev/null

        echo "🔍 Recherche du dossier de config JetBrains Rider..."
        CONFIG_DIR=$(find ~/.config/JetBrains -maxdepth 1 -type d -name "Rider*" | sort -r | head -n1)/options

        if [ ! -d "$CONFIG_DIR" ]; then
          echo "❌ Dossier de configuration Rider introuvable."
          exit 1
        fi

        echo "✏️ Modification des fichiers XML..."
        for FILE in editor.xml editor-font.xml ui.lnf.xml; do
          TARGET="$CONFIG_DIR/$FILE"
          if [ -f "$TARGET" ]; then
            sed -i "s/\(<option name=\"\(FONT_FACE\|EDITOR_FONT_NAME\|FONT_NAME\)\" value=\"\)[^\"]*\(\"\/>\)/\1Obelix Pro\3/g" "$TARGET"
          fi
        done

        echo "✅ Police ObelixPro installée et configurée pour JetBrains Rider !"
        echo "🧠 Redémarre Rider pour voir les changements."
      '';
    };
  };
}
