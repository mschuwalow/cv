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

          installPhase = ''
            install -D build/cv.pdf $out/cv.pdf
          '';

          buildInputs = with pkgs;
            [gnumake fd rsync which texliveEnv] ++ devPackages;
        };
    in {
      formatter = pkgs.alejandra;
      packages = {cv = mkPackage false;};
      devShell = mkPackage true;
    });
}
