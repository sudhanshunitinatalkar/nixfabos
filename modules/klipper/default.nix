{
  flake.nixosModules.klipper = { pkgs, lib, ... }: {
    
    services.klipper = {
      enable = true;
      configFile = "/var/lib/klipper/printer.cfg";
    };

    # 2. Create the Klipper user and grant hardware access
    users.users.klipper = {
      isSystemUser = true;
      group = "klipper";
      extraGroups = [ "dialout" "tty" ]; # Required to talk to the MCU over USB/Serial
    };
    users.groups.klipper = {};

    # 3. Provision the mutable folder on boot
    systemd.tmpfiles.rules = [
      "d /var/lib/klipper 0775 klipper klipper - -"
    ];

  };
}