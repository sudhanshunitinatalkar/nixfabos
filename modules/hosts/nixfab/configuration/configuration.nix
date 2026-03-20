{
  flake.nixosModules.nixfabos = { inputs, pkgs, ... }:
  {
    users.users.nixfab = 
    {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "gpio" ];
    };

    nix.settings = 
    {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "nixfab" ];
    };
    system.stateVersion = "25.11";
    nixpkgs.config.allowUnfree = true;

    boot =
    {
      binfmt.emulatedSystems = [ "aarch64-linux" ];
      kernelPackages = pkgs.linuxPackages_latest;
      
      loader =
      {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };

      consoleLogLevel = 0; # Set to 0 to suppress almost all kernel text
      initrd.verbose = false;
      
      kernelParams = [
        "quiet"
        "splash"           # Explicitly trigger the splash screen
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_level=3"
        "fbcon=nodefer"    # Prevents delay in framebuffer initialization
        "reboot=pci"       # Your Lenovo reboot fix
        "vt.global_cursor_default=0" # Hides the blinking cursor during boot
      ];
    };

    hardware.bluetooth.enable = true;

    networking =
    {
      hostName = "nixfabos";
      networkmanager.enable = true;
      firewall.enable = false;
      # firewall.allowedTCPPorts = [ ];
      # firewall.allowedUDPPorts = [ ];
    };


    time = {
      timeZone = "Asia/Kolkata";
    };
    
    services =
    {
      openssh.enable = true;
    };

    environment.systemPackages = with pkgs;
    [
      tree
      util-linux
      vim
      wget
      curl
      git
      gptfdisk
      htop
      pciutils
      home-manager
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    console =
    {
      keyMap = "us";
    }; 

  };
}
