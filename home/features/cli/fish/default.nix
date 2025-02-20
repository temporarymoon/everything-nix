{ pkgs, config, lib, ... }:
let
  repaint = "commandline -f repaint";
  fishKeybinds = {
    # C-x to clear screen
    "\\cx" = "clear && ${repaint}";
    # C-z to return to background process
    "\\cz" = "fg && ${repaint}";
    # C-y to yank current command
    # TODO: make this work in xorg as well
    "\\cy" = "wl-copy \$(commandline)";
    # C-e to launch $EDITOR
    "\\ce" = "$EDITOR";
    # C-S-e to edit commandline using $EDITOR
    "\\e\\[69\\;5u" = "edit_command_buffer";
    # C-enter to run command through a pager
    "\\e\\[13\\;2u" = "commandline -a ' | $PAGER' && commandline -f execute";
    # C-g to open lazygit
    "\\cg" = "lazygit";
  };

  mkKeybind = key: value:
    let escaped = lib.escapeShellArg value;
    in
    ''
      bind -M default ${key} ${escaped}
      bind -M insert  ${key} ${escaped}
    '';
in
{
  # {{{ Fzf 
  programs.fzf = {
    enable = true;
    defaultOptions = [ "--no-scrollbar" ];

    changeDirWidgetOptions = [
      "--preview '${lib.getExe pkgs.eza} --icons --tree --color=always {}'"
    ];

    fileWidgetOptions = [
      "--preview '${lib.getExe pkgs.bat} --number --color=always {}'"
    ];
  };

  stylix.targets.fzf.enable = true;
  # }}}
  # {{{ Fish
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # ❄️ Fish keybinds generated using nix ^~^
      function fish_nix_key_bindings
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkKeybind fishKeybinds)}
      end

      ${builtins.readFile ./config.fish}

      # Modify nix-shell to use `fish` as it's default shell
      ${lib.getExe pkgs.nix-your-shell} fish | source
    '';

    # {{{ Plugins 
    plugins =
      let
        plugins = with pkgs.fishPlugins; [
          z # Jump to directories by typing "z <directory-name>"
          grc # Adds color to a bunch of built in commands
          done # Trigger a notification when long commands finish execution
          puffer # Text expansion (i.e. expanding .... to ../../../)
          sponge # Remove failed commands and whatnot from history
          forgit # Git tui thingy? (I'm still trying this one out)
          colored-man-pages # Self explainatory:)
        ];
      in
      # For some reason home-manager expects a slightly different format 🤔
      lib.forEach plugins
        (plugin: {
          name = plugin.pname;
          inherit (plugin) src;
        });
    # }}}
  };

  # I sometimes get errors about `grc` being missing, so I gave up and added it here.
  home.packages = [ pkgs.grc ];

  satellite.persistence.at.state.apps.fish.directories = [
    "${config.xdg.dataHome}/fish"
    "${config.xdg.dataHome}/z" # The z fish plugin requires this
  ];
  # }}}
}
