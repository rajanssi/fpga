{
  description = "FPGA Development Environment with GTKWave";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "gtkwave-shell";

        # Packages to make available in the shell
        buildInputs = with pkgs; [
          gtkwave
          # I've added these common dependencies just in case you need them
          # for other parts of your CAD suite usage:
          libxkbcommon
          dbus
          glib
        ];

        # Environment variables to fix X11/Wayland path issues
        shellHook = ''
          echo "Welcome to the NixOS GTKWave environment."
          
          # Fix for "xkbcommon: ERROR: failed to add default include path"
          export XKB_CONFIG_ROOT=${pkgs.xkeyboard_config}/share/X11/xkb
          
          # Ensure we don't accidentally pull in the broken libs from OSS-CAD-SUITE
          # if you had previously sourced their environment script.
          unset LD_LIBRARY_PATH
        '';
      };
    };
}
