 {
  description = "A Digital Nix Ocean";
  inputs = {

    ### Basically required
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    ### My extra inputs

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rom-properties = {
      url = "github:Whovian9369/rom-properties-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ninfs = {
      url = "github:ihaveamac/ninfs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Lix! Lix! Lix!

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix";
        /*
          Future me, the pattern for using Forgejo URLs is:
          git+https://git@${domain}/${user_org}/${repo}?ref=refs/tags/${TAG}
          git+https://git@${domain}/${user_org}/${repo}?rev=${commitHash}
        */
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
        /*
          Future me, the pattern for using Forgejo URLs is:
          git+https://git@${domain}/${user_org}/${repo}?ref=refs/tags/${TAG}
          git+https://git@${domain}/${user_org}/${repo}?rev=${commitHash}
        */
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    #########
    # Extra inputs that I am adding just to make my life easier,
    # but don't like that they're included >:(
    #########

    /*
      Used by:
      - lix
    */
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };

    /*
      Used by:
      - lix-module
    */
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "nix-systems_default";
    };

    /*
      Used by:
      - agenix
      - flake-utils
    */
    nix-systems_default = {
      url = "github:nix-systems/default";
    };


  }; # inputs

  outputs = { self, nixpkgs, home-manager, flake-programs-sqlite, rom-properties, ninfs, lix-module, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    # Notes
      /*
        $ nix build .#nixosConfigurations.cresselia.config.system.build.toplevel
          should let me build the "cresselia" system config, similar to using
          $ nixos-rebuild build .#cresselia 
        $ nix build .#nixosConfigurations.cresselia.config.system.build.digitalOceanImage
          should let me build the "cresselia" system config, as an image for
          use to create a Digital Ocean Droplet...
          ... Hopefully.
      */

    nixosConfigurations = {
      cresselia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          ./docker.nix
          flake-programs-sqlite.nixosModules.programs-sqlite
          home-manager.nixosModules.home-manager
          lix-module.nixosModules.default

        {

          ### Home-Manager ###
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              users = {
                whovian = {
                  imports = [
                    ./whovian/home.nix
                  ];
                };
              # TODO: Enable when/if vgmoose wants to use home-manager
              /*
                vgmoose = {
                  imports = [
                    ./vgmoose/home.nix
                  ];
              */
              };
            };

        ### SYSTEM SETTINGS ###

            users = {
                defaultUserShell = pkgs.zsh;
                groups = {
                  whovian = {};
                  vgmoose = {};
                };

              users = {
                whovian = {
                  name = "whovian";
                  description = "Whovian9369";
                  shell = pkgs.zsh;
                  initialPassword = "abcde"; # I need to log in somehow
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                      # Enable 'sudo' for the user.
                  ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUpUbEtBSySMW82Wm4xOtlGKxnPf8bqKxVMRJH3Sycx"
                  ];
                };

                vgmoose = {
                  name = "vgmoose";
                  description = "vgmoose";
                  shell = pkgs.zsh;
                  initialPassword = "abcde"; # Moose needs to log in somehow
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                      # Enable 'sudo' for the user.
                  ];
                  openssh.authorizedKeys.keys = [
                    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHag4ppJlW3BXnntJ34Ok0i6gIFAzKlZLEZqBq2eTFpCPFXV3d5PulPxqqidue/jbQZW2KseSX5BATbMmlMCgw4="
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1I4NAoz8PoHgL6Zs4kS/NJfhYtAgPdEGrQ3rZoQCrGQDfGAwVJ8kmHeCf83qJYrPwtWIxWrPMtpxWE2/LJzPVkbHWqsHj/XHF/AL9i++DAx9vOx5/UQnUoTdxz0qZHX6VJJgTS0yT7b3kURxLHyw/u/4fIKWlClxtHS8FjC9Wrb4req9yiZZTccGaQ2hGfaEG5zfT2X3K+oPcooYd28KujG0s4ufn70MRzEWwIUQiF/UKefQJ3ohMZ7r/DE2cjMhGKru/zZltZXgjnnxajh4fAH74Q4oRYCdoCAQcnGhvDMx4ka7sGkoGwvpiE3tarZtvmRIz2/vhfYcy1BBL+K8umPgVGGDpYWSQCrpIiHhjE1pagtLM1g4ert2CwmIY9ueAkokmkmT9AwWTPsLvvidOxtML0AfaqN/v51ZHOSzrNVkV40vaqpnbWYQGHaLdXHJAPCxZEK2cvfzugeaohbEAFWiVZHjCC+ciCxI5hvpsM2FcHQnIFp49mhkOwPFFqu8="
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEsu43DNQ0Nwauszqht5bXnCXcBwsz10w8wGJQ/qzjUmPjag2LJUxopPR/q7PhfPsbveXYI3w+QOU6dtQjkG1FkGaOFp/K/bNcAeUi9uRvg2sO2t5SOR+lIXtYcYtYjz7B4IsCZFcN54S8muDDsEFe0NWB7wxAVJOy1zA8eAg0MdyNPa81kxRAhmWD/uey3RDDE8/JuvS7GNL/tMONHnBqYdLG1LMOe1PeyUPoSPnSJwygkoHeojREFk3J0gq+VH/nqVTb9c8v00D/qg228K/KaS6z0QqUSqQ4qA4nXLjm33AXw+Tpjmbe3KSm0ebaRwamAbMF4t1HAtD9kwgkpDhmLP7oju/R7Vwvhm5hrgXDt5iOlMtBFsNYW2bOjGvu2wKkzQzI8etnMdDum3EgRFOiFUdVfKp/jPG0wyGTSghnVtKKGp1J8dlYTGgiHh7I2Qc7eMnrum15V+7bGiNJ9UsYrEmdqXc4L5lasa579k6V78tTY7Iqm483gKTj4cDYMzE="
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM1a91pl8eRpwEHIfWiPKNMo+21iJiDgH+LndCUSGxNEQMZHsBsan1L0PRrSTrFMJ1ERIDroy9vxTZxHxSmr9N7suX9EGTqsDwghWmQ50kBnXA0X+z7jAac4GavRjZPCJ9F7dMeYRqkDp3BrtsOKCKelECuqpf6iZasAkXZAQOrwqvS7RW/qhAEoKF5GwVeRkPaZ8YP1nFpIujvkR3IObtyCUQKeX0MVI8lnhPPEVT2RI2n/e4FPqFb+3U49tE1jkgo8811FrBYui3/x1w+6gvz3Ne9kNzyjTrkX+5l+PLWdoTj3gFbMWgPyIXzPnWCAj5Hopn4JnnlUYt3FobNf0DHRiE3cGUQpr0HX9Hiy/5qJz4Ofou7QwYsVEnw/sSOfIfAw+y4iwOirsiIBlj9pLvZ6dZWGPk+CYa5wa0PJFvXbicoFXP62XAspICocNr78oFAvM3tGIvPAwOmPPQhW4XeWsJmHuzCw1CQB2UgQx/G9exezxzlIaL1BFfF72Iq3M="
                  ];
                };
              };
            };

            system = {
              configurationRevision = self.shortRev or self.dirtyShortRev or "dirty";
              stateVersion = "25.05";
                # DO NOT CHANGE THIS
            };

          virtualisation.digitalOceanImage.compressionMethod = "bzip2";

          /*
            boot.loader = {
              systemd-boot = {
                enable = true;
                editor = false;
              };
            };
          */

            networking.hostName = "cresselia";

            time.timeZone = "America/New_York";

            nix = {
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              settings = {
                trusted-users = [
                  "whovian"
                  "vgmoose"
                ];
              };
            };

            environment.systemPackages = [
              pkgs._7zz
              pkgs.bat
              pkgs.croc
              pkgs.curl
              pkgs.dhex
              pkgs.fd
              pkgs.file
              pkgs.git
              pkgs.jq
              pkgs.lynx
              pkgs.ncdu
              pkgs.progress
              pkgs.ripgrep
              pkgs.unrar
              pkgs.wget
              pkgs.xxd
              pkgs.yq
              ninfs.packages.x86_64-linux.ninfs
              rom-properties.packages.x86_64-linux.default
            ];

            environment.shells = [
              pkgs.zsh
            ];

            programs = {
              nano.enable = true;
              screen.enable = true;
              zsh = {
                enable = true;
                shellInit = '' zsh-newuser-install () {} '';
                ohMyZsh = {
                  enable = true;
                  theme = "bira";
                };
              };
              nix-index = {
                enable = true;
                enableBashIntegration = false;
                enableZshIntegration = false;
              };
            };

            services = {
              do-agent.enable = true;
              openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  PermitRootLogin = "no";
                  KbdInteractiveAuthentication = false;
                };
              };
            };

            swapDevices = [
              {
                device = "/swapfile";
                # size = 4*1024;
                size = 4096;
                  # in MB
              }
            ];
        ### SYSTEM SETTINGS ###
          }
        ];
      };
    };
  };
}
