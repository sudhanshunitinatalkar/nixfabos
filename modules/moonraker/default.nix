{
  flake.nixosModules.moonraker = { config, lib, pkgs, ... }: {
    
    services.moonraker = {
      enable = true;
      
      # Tell Moonraker to listen on all network interfaces
      address = "0.0.0.0";
      port = 7125;

      # The core configuration injected directly into moonraker.conf
      settings = {
        server = {
          # Point Moonraker to the default socket NixOS creates for Klipper
          klippy_uds_address = "/run/klipper/api_socket";
        };
        
        machine = {
          # Tell Moonraker that NixOS uses systemd to manage services
          provider = "systemd_cli";
        };

        authorization = {
          # Stupid simple security: Allow any local network IP to access the API.
          # This ensures Mainsail can connect without logging in during testing.
          cors_domains = [
            "*"
          ];
          trusted_clients = [
            "10.0.0.0/8"
            "127.0.0.0/8"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "FE80::/10"
            "::1/128"
          ];
        };
      };
    };

  };
}