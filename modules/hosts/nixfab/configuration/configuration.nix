{
  flake.nixosModules.nixfabos = { inputs, pkgs, lib, ... }:
  {

    users.groups.gpio = {};

    users.users.root = 
    {
      initialPassword = "nixfabos";
    };

    users.users.nixfab = 
    {
      initialPassword = "nixfab";
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "gpio" ];
    };

     nixpkgs.overlays = [
      (final: prev: {
        makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      })
      
      # --- THE UART FIX (UPDATED) ---
      (final: prev: {
        ubootRaspberryPi3_64bit = prev.ubootRaspberryPi3_64bit.overrideAttrs (old: {
          extraConfig = (old.extraConfig or "") + ''
            # 1. Skip the initial U-Boot shell check
            CONFIG_BOOTDELAY=-2
            
            # 2. Enable the "Null" device (a dummy input)
            CONFIG_SYS_DEVICE_NULLDEV=y
            
            # 3. SILENCE EVERYTHING
            CONFIG_SILENT_CONSOLE=y
            CONFIG_SILENT_CONSOLE_UPDATE_ON_SET=y
            
            # 4. Force U-Boot to use the Null device for input immediately
            CONFIG_USE_PREBOOT=y
            CONFIG_PREBOOT="setenv stdin nulldev"
          '';
        });
      })
    ];
 
    nix.settings = 
    {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "nixfab" ];
    };


    system.stateVersion = "25.11";
    nixpkgs.config.allowUnfree = true;

    boot =
    {
      kernelPackages = pkgs.linuxPackages_rpi02w;
      supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
      
      tmp.useTmpfs = false;
      tmp.cleanOnBoot = true;
      loader.grub.enable = false;
      loader.generic-extlinux-compatible = {
          enable = true;
      };
      # Force the timeout to 1 second
      loader.timeout = lib.mkForce 1;
      

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

    hardware.bluetooth.enable = false;

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
      i2c-tools
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    console =
    {
      keyMap = "us";
    }; 

  };
}
