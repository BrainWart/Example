{
  inputs = {
    nixpkgs.url = "github:brainwart/nixpkgs/brainwart/dotnet-packageLockJson";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      self,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        packageName = "Example";
        pkgs = nixpkgs.legacyPackages.${system};
        dotnet-sdk = pkgs.dotnet-sdk_8;
        dotnet-runtime = pkgs.dotnet-runtime_8;
      in
      {
        packages = {
          default = pkgs.buildDotnetModule {
            inherit dotnet-runtime dotnet-sdk;

            pname = packageName;
            version = "0.0.0";

            src = ./.;
            nugetDeps = ./packages.lock.json;
            nugetDepsIsLockFile = true;

            projectFile = "${packageName}.sln";
          };
        };

        apps =
          let
            systemPackage = self.packages.${system};
          in
          {
            default = {
              type = "app";
              program = "${systemPackage.default}/bin/${packageName}";
            };
          };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            dotnet-sdk
            pkgs.omnisharp-roslyn
            pkgs.nixfmt-rfc-style
            pkgs.nil
          ];
        };
      }
    );
}
