# Common wayland stuff
{ lib, pkgs, upkgs, ... }: {
  imports = [ ../common/wofi.nix ];
  # Makes some stuff run on wayland (?)
  # Taken from [here](https://github.com/fufexan/dotfiles/blob/3b0075fa7a5d38de13c8c32140c4b020b6b32761/home/wayland/default.nix#L14)
  # TODO: ask author what those do
  # home.sessionVariables = {
  #   QT_QPA_PLATFORM = "wayland";
  #   SDL_VIDEODRIVER = "wayland";
  #   XDG_SESSION_TYPE = "wayland";
  # };

  # TODO: set up
  # - screen recording
  # - volume/backlight controls
  # - eww bar
  # - configure hyprland colors using base16 stuff
  # - look into swaylock or whatever people use
  # - look into greetd or something
  # - multiple keyboard layouts
  # - wallpaper
  # - notification daemon

  home.packages =
    let
      _ = lib.getExe;

      # Taken from [here](https://github.com/fufexan/dotfiles/blob/3b0075fa7a5d38de13c8c32140c4b020b6b32761/home/wayland/default.nix#L14)
      wl-ocr = pkgs.writeShellScriptBin "wl-ocr" ''
        ${_ pkgs.grim} -g "$(${_ pkgs.slurp})" -t ppm - \
          | ${_ pkgs.tesseract5} - - \
          | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    in
    with pkgs; [
      # utils
      wl-ocr # Custom ocr script
      wl-clipboard # Clipboard manager
      wlogout # Nice logout script
      # REASON: not available on stable yet
      upkgs.hyprpicker # Color picker

      # screenshot related tools
      grim # Take screenshot
      slurp # Area selector
    ];
}
