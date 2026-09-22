# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
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
  
  # 仅保留系统级 / 基础必备；其余用户应用已移入 home.nix（home.packages）
  environment.systemPackages = with pkgs; [
    curl                # 基础网络工具（root/脚本也用得到）
    wget                # 基础网络工具
    gcc                 # 系统级编译器（如 nvim-treesitter 现编解析器）
    lsof                # 诊断工具
    networkmanagerapplet # 网络托盘图标
    file-roller         # 归档管理器（thunar-archive-plugin 依赖）
    xdg-terminal-exec   # 系统级默认终端
    xdg-user-dirs       # 基础 XDG 用户目录
    adwaita-icon-theme  # 系统图标主题
  ];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      auto-optimise-store = true;
      extra-trusted-users = [ "lzg" ];
      # the system-level substituers & trusted-public-keys
      # given the users in this list the right to specify additional substituters via:
      #    1. `nixConfig.substituers` in `flake.nix`
      substituters = [
        # 只用官方源：USTC/TUNA 等 nix-channels 镜像不完整，缺包会刷 cache-miss 噪音，故不启用
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        # the default public key of cache.nixos.org, it's built-in, no need to add it here
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

   # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # FIXME: Add the rest of your current configuration

  # TODO: Set your hostname
  networking.hostName = "nixos";

  # Set your time zone.
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  users.users.root = {
    initialHashedPassword = "$6$kWg6iZqd4bCiQYSg$1dxeAroSKDsT7cDVWavdhCzxS.mv4reYtMCofQ6.W6vFZYMHXAc3mWNYLl5NK0p7kKTnWuzlFIeK3ntOzWhka1";
  };
  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    lzg = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialHashedPassword = "$6$kWg6iZqd4bCiQYSg$1dxeAroSKDsT7cDVWavdhCzxS.mv4reYtMCofQ6.W6vFZYMHXAc3mWNYLl5NK0p7kKTnWuzlFIeK3ntOzWhka1";
      description = "lizhengang";
      isNormalUser = true;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel"];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # users.users.lzg.shell = pkgs.fish 需要此项：否则 NixOS 断言失败
  # （fish 会缺少 nix profile 的 PATH，可能导致无法登录）。
  # 这是系统级 /etc/fish，与 home-manager 接管的 ~/.config/fish 不冲突。
  programs.fish.enable = true;

  programs.hyprland.enable = true;

  # 允许运行"外来"的通用动态链接二进制（nix-ld）。
  # nvim-treesitter 运行时编译语法解析器、mason 下载的 LSP 等都会去调用非 nix 的
  # 动态链接可执行文件，NixOS 默认拒绝启动它们，报：
  #   Could not start dynamically linked executable: ...
  #   NixOS cannot run dynamically linked executables ... https://nix.dev/permalink/stub-ld
  # 开启 nix-ld 即为这类程序提供兼容的动态链接器与运行库。
  programs.nix-ld.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.tuigreet}/bin/tuigreet --user-menu --user-menu-min-uid 1000 --remember --remember-session --time --issue --asterisks";
        user = "greeter";
      };
    };
  };

  virtualisation.vmware.guest.enable = true;

  programs.thunar = {
    enable = true;
    # thunar-archive-plugin / thunar-volman 已从 pkgs.xfce.* 提到顶层
    plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
  };

  xdg.mime.defaultApplications = { "inode/directory" = "thunar.desktop"; };

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # PipeWire：wf-recorder --audio（带声录屏）、mpd 的 pulse 输出、
  # waybar 音量模块 / pulsemixer 都依赖它；此前全仓没有任何音频栈配置。
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;   # 提供 pipewire-pulse，兼容 pulse 客户端
  };

  environment.etc."issue".text = "\\S{prettyName} \\r (\\l)";

  environment.etc = {
      "/wireplumber/wireplumber.conf.d/alsa-vm.conf" = {
        source = ./alsa-vm.conf;
      };
  };

  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # 锁定到 580 长期支持分支（production），支持 GTX 1080（Pascal 架构）；
    # stable 未来可能随 NVIDIA 新分支漂移到 590，而 590 不再支持 Pascal。
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
