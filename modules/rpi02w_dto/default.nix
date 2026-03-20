{
    flake.nixosModules.rpi02w_dto = { pkgs, lib, ... }:

    {
    # 1. Device Tree & Overlays (Hardware Definitions)
    hardware = {
        enableRedistributableFirmware = lib.mkForce true;
        i2c.enable = true;

        deviceTree = {
        enable = true;
        filter = "*rpi-zero-2-w.dtb";
        overlays = [
            # I2C Enable Overlay
            {
            name = "enable-i2c";
            dtsText = ''
                /dts-v1/;
                /plugin/;
                / {
                    compatible = "brcm,bcm2837";
                    fragment@0 {
                        target = <&i2c1>;
                        __overlay__ {
                            status = "okay";
                        };
                    };
                };
            '';
            }
            
            # DS3231 RTC Overlay
            {
            name = "ds3231-i2c";
            dtsText = ''
                /dts-v1/;
                /plugin/;
                / {
                    compatible = "brcm,bcm2837";
                    fragment@0 {
                        target = <&i2c1>;
                        __overlay__ {
                            ds3231@68 {
                                compatible = "maxim,ds3231";
                                reg = <0x68>;
                            };
                        };
                    };
                };
            '';
            }
            
            # Disable Bluetooth / Enable PL011 UART
            {
            name = "disable-bt";
            dtsText = ''
                /dts-v1/;
                /plugin/;
                / {
                    compatible = "brcm,bcm2837";
                    /* 1. Disable the "Bad" Mini UART */
                    fragment@0 {
                        target = <&uart1>;
                        __overlay__ { status = "disabled"; };
                    };
                    /* 2. Enable the "Good" PL011 UART */
                    fragment@1 {
                        target = <&uart0>;
                        __overlay__ {
                            pinctrl-names = "default";
                            pinctrl-0 = <&uart0_pins>;
                            status = "okay";
                        };
                    };
                    /* 3. Kill the Bluetooth module */
                    fragment@2 {
                        target = <&bt>;
                        __overlay__ { status = "disabled"; };
                    };
                    /* 4. CONFIGURE THE PINS */
                    fragment@3 {
                        target = <&uart0_pins>;
                        __overlay__ {
                            brcm,pins = <14 15>; /* GPIO 14 (TX) & 15 (RX) */
                            brcm,function = <4>; /* Alt4 = PL011 UART */
                            brcm,pull = <0 2>;   /* No pull on TX, Pull-up on RX */
                        };
                    };
                    /* 5. Release the old Bluetooth pins */
                    fragment@4 {
                        target = <&bt_pins>;
                        __overlay__ {
                            brcm,pins = <>;
                            brcm,function = <0>;
                            brcm,pull = <2>;
                        };
                    };
                    /* 6. Update Aliases */
                    fragment@5 {
                        target-path = "/aliases";
                        __overlay__ {
                            serial0 = "/soc/serial@7e201000";
                            serial1 = "/soc/serial@7e215040";
                        };
                    };
                };
            '';
            }

            # ENC28J60 Ethernet Overlay
            {
                name = "enc28j60-overlay";
                dtsText = ''
                /dts-v1/;
                /plugin/;
                / {
                    compatible = "brcm,bcm2837";
                    fragment@0 {
                        target = <&spi0>;
                        __overlay__ {
                            status = "okay";
                            spidev@0 { status = "disabled"; };
            
                            eth1: enc28j60@0 {
                                compatible = "microchip,enc28j60";
                                reg = <0>;
                                pinctrl-names = "default";
                                pinctrl-0 = <&eth1_pins>;
                                interrupt-parent = <&gpio>;
                                interrupts = <25 2>; 
                                spi-max-frequency = <25000000>;
                                status = "okay";
                            };
                        };
                    };
                    fragment@1 {
                        target = <&gpio>;
                        __overlay__ {
                            eth1_pins: eth1_pins {
                                brcm,pins = <25>;
                                brcm,function = <0>; 
                                brcm,pull = <2>; 
                            };
                        };
                    };
                };
                '';
            }
        ];
        };
    };

    # 2. Kernel Modules & Udev Rules
    boot.kernelModules = [ "enc28j60" "bcm2835_wdt" ];
    services.udev.extraRules = ''
        KERNEL=="ttyAMA0", MODE="0660", GROUP="dialout"
        SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
        SUBSYSTEM=="gpiodev", GROUP="gpio", MODE="0660"
        KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
    '';
    
    # Disable the console on serial getting in the way
    systemd.services."serial-getty@ttyAMA0".enable = false;

    # 3. BUILD-TIME CONFIG.TXT GENERATION (The Fix)
    # This appends to the file generated by the base image during the build.
    sdImage.populateFirmwareCommands = ''
        (
        echo "    "
        echo "# --- Custom User Overrides ---"
        echo "enable_uart=1"
        echo "dtparam=spi=on"
        echo "dtoverlay=disable-bt"
        echo "dtparam=watchdog=on"
        ) >> firmware/config.txt
    '';
    };
}