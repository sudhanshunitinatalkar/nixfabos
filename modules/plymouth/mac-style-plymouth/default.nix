{
  flake.nixosModules.mac-style-plymouth = { inputs, pkgs, ... }: {
    
    nixpkgs.overlays = [
      inputs.mac-style-plymouth.overlays.default
    ];

    boot.plymouth = {
      enable = true;
      theme = "mac-style";
      themePackages = [ pkgs.mac-style-plymouth ];
    };

    # Fix #1: Ensure SDDM and Plymouth don't fight over the GPU
    systemd.services.display-manager = {
      after = [ "plymouth-quit-wait.service" ];
      wants = [ "plymouth-quit-wait.service" ];
    };

    # Fix #4: Broaden the shutdown/reboot triggers to ensure Plymouth always quits
    systemd.services."plymouth-quit".wantedBy = [ "reboot.target" "halt.target" "poweroff.target" ];
  };
}