# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "lzg";
    homeDirectory = "/home/lzg";
  };
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    jq
    # 添加其他你需要的用户级软件包
    neovim
    waybar
    rofi-wayland
    kitty
    fish
    starship
    fastfetch
    nwg-look
    xdg-user-dirs
    nix-search-cli
    btop
    pulsemixer
    wl-clipboard
    vscode
    waypaper
    swww
    ncmpcpp
    # 开发工具、GUI应用等
  ];
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  services.mpd = {
    enable = true;
    musicDirectory = "/home/lzg/音乐/Music";
    extraConfig = ''
    # must specify one or more outputs in order to play audio!
    # (e.g. ALSA, PulseAudio, PipeWire), see next sections
    '';

    # Optional:
    # network.listenAddress = "any"; # if you want to allow non-localhost connections
    # network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };
  services.mpd-mpris.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
      fcitx5-chinese-addons  # table input method support
      fcitx5-nord            # a color theme
    ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
