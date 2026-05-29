{
  description = "Dev shell for galoy-infra";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pkgsUnstable = import nixpkgs-unstable {inherit system;};
      terraformResourceSrc = pkgs.fetchFromGitHub {
        owner = "ljfranklin";
        repo = "terraform-resource";
        rev = "2eba5a46e96587d0eafcee857ee8591e9e9a8b01";
        hash = "sha256-wSzG/2nC4BPvnLZ4HA2gxYBt9+xTA2KAOVt/1rbAwIQ=";
      };
      tofuResource = pkgs.buildGoModule {
        pname = "tofu-resource";
        version = "2026-05-29";
        src = "${terraformResourceSrc}/src/terraform-resource";
        vendorHash = null;
        subPackages = [
          "cmd/check"
          "cmd/in"
          "cmd/out"
        ];
        postInstall = ''
          mkdir -p $out/opt/resource
          mv $out/bin/check $out/opt/resource/check
          mv $out/bin/in $out/opt/resource/in
          mv $out/bin/out $out/opt/resource/out
        '';
      };
      tofuResourceImage = pkgs.dockerTools.streamLayeredImage {
        name = "us.gcr.io/galoyorg/tofu-resource";
        tag = "latest";
        architecture = "amd64";
        maxLayers = 4;
        contents = [
          tofuResource
          pkgsUnstable.opentofu
          pkgsUnstable.cacert
        ];
        extraCommands = ''
          mkdir -p tmp usr/local/bin root/.ssh
          chmod 1777 tmp
          ln -s /bin/tofu usr/local/bin/terraform
          printf '%s\n' 'StrictHostKeyChecking no' 'LogLevel quiet' > root/.ssh/config
          chmod 0600 root/.ssh/config
        '';
        config = {
          Env = ["PATH=/usr/local/bin:/bin"];
        };
      };
    in
      with pkgs; {
        packages = {
          tofu-resource-image = tofuResourceImage;
        };

        devShells.default = mkShell
          {
            nativeBuildInputs = [
              alejandra
              opentofu
              ytt
              (azure-cli.withExtensions [azure-cli.extensions.ssh])
              jq
            ];

            shellHook = ''
              # Read Azure profile and set subscription ID
              if [ -f ~/.azure/azureProfile.json ]; then
                export ARM_SUBSCRIPTION_ID=$(jq -r '.subscriptions[0].id' ~/.azure/azureProfile.json)
                echo "Set ARM_SUBSCRIPTION_ID to $ARM_SUBSCRIPTION_ID"
              else
                echo "Warning: ~/.azure/azureProfile.json not found, do az login"
              fi
            '';
          };

        formatter = alejandra;
      });
}
