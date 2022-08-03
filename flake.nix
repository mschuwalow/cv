{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-22.05-darwin";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      texliveEnv = pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-medium
          moderncv
          fontawesome5
          ebgaramond
          multirow
          arydshln
          ;
      };

      mkPackage = isShell: let
        devPackages = with pkgs;
          lib.optionals isShell [fontconfig];
      in
        pkgs.stdenv.mkDerivation {
          name = "cv";

          src =
            if isShell
            then null
            else self;

          buildInputs = with pkgs;
            [gnumake fd rsync which texliveEnv] ++ devPackages;

          preBuild = ''
            export HOME=$(mktemp -d)
          '';

          installPhase = ''
            install -D build/cv.pdf $out/cv.pdf
          '';

          SOURCE_DATE_EPOCH = self.lastModified;
        };
    in {
      formatter = pkgs.alejandra;
      packages = rec {
        cv = mkPackage false;
        default = cv;
      };
      devShell = mkPackage true;
    });
}
