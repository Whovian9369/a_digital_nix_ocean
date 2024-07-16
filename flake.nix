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

  }; # inputs

  outputs = { self, nixpkgs, home-manager, flake-programs-sqlite, ... }:
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
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix"
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          # ./vnc.nix
          ./docker.nix
          home-manager.nixosModules.home-manager
          flake-programs-sqlite.nixosModules.programs-sqlite

          {
          ### (Hopefully) Replacing /etc/nixos/configuration.nix
            imports = nixpkgs.lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
              ("${nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix")
            ];
          }

          {
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
                };
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
                compucat = {
                  name = "compucat";
                  description = "Compucat";
                  shell = pkgs.zsh;
                  initialPassword = "abcde"; # I need to log in somehow
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                      # Enable 'sudo' for the user.
                  ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5B9hJ2GAgKEFBi/5r7xYpWpEyZDZ1/K4V2/q4Lh/iV"
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOj07g4lkqwRNfLg8UlZXs3s90NRsUyDm2ycikQU2oaf"
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
              stateVersion = "24.11";
                # DO NOT CHANGE THIS
            };

            # TODO: Possibly remove/fix this as needed whenever
            # github:NixOS/nixpkgs/issues/308404 gets fixed.
            boot.loader.grub = {
              device = "/dev/vda";
              devices = nixpkgs.lib.mkForce ["/dev/vda"];
            };

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
              pkgs.wget
              pkgs.xxd
              pkgs.yq
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
              command-not-found = {
                enable = true;
                dbPath = flake-programs-sqlite.packages.${system}.programs-sqlite;
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
