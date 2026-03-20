{
  flake.nixosModules.mainsail = { config, lib, pkgs, ... }: {
    
    # 1. Enable the Mainsail web interface
    # This automatically installs Nginx and serves the Mainsail application on port 80.
    services.mainsail.enable = true;

    # 2. Fix the Nginx file upload limit (Crucial!)
    # By default, Nginx blocks any file upload larger than 1MB. 
    # Since 3D printer G-Code files are often hundreds of megabytes, 
    # we must explicitly tell the web server to accept up to 1 Gigabyte.
    services.nginx = {
      clientMaxBodySize = "1024m"; 
    };

  };
}