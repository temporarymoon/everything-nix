{ lib, ... }: {
  imports = [
    ../common/global
    ../common/users/guest.nix

    ../common/optional/greetd.nix
    ../common/optional/pipewire.nix
    ../common/optional/desktop/xdg-portal.nix
    ../common/optional/wayland/hyprland.nix
  ];

  # Usually included in the hardware-configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Set the name of this machine!
  networking.hostName = "euporie";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
