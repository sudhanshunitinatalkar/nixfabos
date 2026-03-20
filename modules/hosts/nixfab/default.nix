{ inputs, config, ... }: 
{
  flake.nixosConfigurations."cosmoslaptop" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      config.flake.nixosModules.nixfabos
      config.flake.nixosModules.rpi02w_dto
      config.flake.nixosModules.mac-style-plymouth      
    ];
  };
}