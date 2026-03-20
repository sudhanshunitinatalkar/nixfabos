{ inputs, config, ... }: 
{
  flake.nixosConfigurations."nixfabos" = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      config.flake.nixosModules.nixfabos
      config.flake.nixosModules.rpi02w_dto
      config.flake.nixosModules.mac-style-plymouth      
      config.flake.nixosModules.klipper
      config.flake.nixosModules.moonraker
      config.flake.nixosModules.mainsail
    ];
  };
}