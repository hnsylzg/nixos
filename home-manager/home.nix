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
    waybar
    rofi
    fuzzel
    kitty
    fish
    starship
    fastfetch
    nwg-look
    nix-search-cli
    btop
    pulsemixer
    wl-clipboard
    cliphist
    wl-clip-persist

    # 截图 submap（Print）：grimblast 截图 → swappy 标注 → wl-copy/notify-send
    grimblast
    grim
    slurp
    swappy
    # 录屏 submap（SUPER+SHIFT+R）：waybar/scripts/recorder.sh 依赖
    wf-recorder
    # 通知/进程工具（notify-send、pgrep/pkill/killall/xargs；curl 见系统层）
    libnotify
    procps
    psmisc
    findutils
    # 锁定屏幕（SUPER+SHIFT+E 的 (l)锁定）
    swaylock
    vscode
    google-chrome
    waypaper
    playerctl
    awww
    ncmpcpp
    mpd
    dunst
    # waybar 会调用：蓝牙管理 TUI（蓝牙模块 on-click）、日历 TUI（时钟右键）
    bluetuith
    calcurse
    luarocks
    lazygit
    nodejs
    python3
    python3Packages.pip
    python3Packages.virtualenv
    neovim
    # 提供给 nvim-treesitter 的 tree-sitter CLI；用 nix 版可避免它去下载/调用
    # 非 nix 的动态链接二进制（配合系统层 programs.nix-ld 使用）
    tree-sitter
    # python3Packages.pynvim

    # 开发工具、GUI应用等
  ];
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # mpd 不用 services.mpd：它会生成自己的 ~/.config/mpd/mpd.conf，
  # 与下面部署的 dotfiles 版 mpd.conf 撞车（home-manager 会报 collision）。
  # 改用 dotfiles 的做法：部署 mpd.conf + 用 systemd 用户单元拉起 mpd
  # （ExecStart 走 nix store 路径，NixOS 没有 /usr/bin/mpd）。
  services.mpd-mpris.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
      qt6Packages.fcitx5-chinese-addons  # table input method support
      fcitx5-nord            # a color theme
    ];
  };

  # 关掉激活时那句 "There are 370 unread and relevant news items"。
  # 想读的时候手动跑一次 `home-manager news` 即可。
  news.display = "silent";

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user = {
      name = "hnsylzg";
      email = "hnsylzg@gmail.com";
    };
  };

  # 声明式部署现有 dotfiles（配置源位于 flake 内的 ../config，相对本文件）
  xdg.configFile = {
    # 顶层 flag / 配置文件
    "starship.toml".source = ../config/starship.toml;
    "chrome-flags.conf".source = ../config/chrome-flags.conf;
    "code-flags.conf".source = ../config/code-flags.conf;
    "electron-flags.conf".source = ../config/electron-flags.conf;
    "qq-flags.conf".source = ../config/qq-flags.conf;
    "typora-flags.conf".source = ../config/typora-flags.conf;
    "spotify-launcher.conf".source = ../config/spotify-launcher.conf;
    "xdg-terminals.list".source = ../config/xdg-terminals.list;
    # 程序配置目录
    "kitty".source = ../config/kitty;
    "hypr".source = ../config/hypr;
    "rofi".source = ../config/rofi;
    "waybar".source = ../config/waybar;
    "fuzzel".source = ../config/fuzzel;
    # nvim：逐项符号链接，不要整目录接管。
    # 原因：LazyVim 需要在 ~/.config/nvim/lazyvim.json 里读写 version/extras/news 状态；
    # 整目录符号链接时该文件是只读 → 写入失败，报 "Error executing vim.schedule lua callback"。
    # 逐项接管后 lazyvim.json 落在真实可写的 ~/.config/nvim/ 下，LazyVim 可自行管理。
    "nvim/init.lua".source = ../config/nvim/init.lua;
    "nvim/stylua.toml".source = ../config/nvim/stylua.toml;
    "nvim/lua".source = ../config/nvim/lua;
    "fastfetch".source = ../config/fastfetch;
    # fish（排除 fish_variables，避免只读符号链接导致 universal variables 无法写入）
    "fish/config.fish".source = ../config/fish/config.fish;
    "fish/abbrs.fish".source = ../config/fish/abbrs.fish;
    "fontconfig".source = ../config/fontconfig;
    "xfce4".source = ../config/xfce4;
    # mpd：只接管 mpd.conf 这一个文件，~/.config/mpd 仍是真实可写目录，
    # 这样 mpd 才能写 mpd.db / mpdstate / playlists（整目录符号链接到 store 会只读）。
    "mpd/mpd.conf".source = ../config/mpd/mpd.conf;
    "ncmpcpp".source = ../config/ncmpcpp;
    "swappy".source = ../config/swappy;
    "dunst".source = ../config/dunst;
  };

  # 这些目录必须存在：mpd 音乐库、录屏输出目录、swappy 截图保存目录
  systemd.user.tmpfiles.rules = [
    "d %h/Music/Music 0755 - - -"
    "d %h/.config/mpd 0755 - - -"
    "d %h/.config/mpd/playlists 0755 - - -"
    "d %h/Videos 0755 - - -"
    "d %h/Pictures/Screenshots 0755 - - -"
  ];

  # waybar 交由 systemd 用户服务托管（对齐 dotfiles 的 systemd 启动方式），
  # 不再在 hyprland 里 exec-once 直接拉起。
  # 注意：dotfiles 那份是 Arch 风格（ExecStart=/usr/bin/waybar），NixOS 没有 /usr/bin，
  # 故这里用 home-manager 声明式生成等价单元，路径走 nix store。
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar status bar";
      Documentation = "https://github.com/Alexays/Waybar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      # systemd 用户单元默认不带用户会话的 PATH，而 config.jsonc 里全是裸命令
      # （exec-if 的 pgrep、clipboard 的 cliphist/rofi、pkill -RTMIN+8 等），
      # 缺 PATH 会导致 custom/wf-recorder 的 exec-if 恒为假 —— 模块永远不显示。
      Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:${pkgs.procps}/bin:${pkgs.coreutils}/bin";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1.5";
      ExecStart = "${pkgs.waybar}/bin/waybar";
      ReloadSignal = "SIGUSR2"; # waybar 用 SIGUSR2 重载配置，避免依赖 /bin/kill
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 对应 dotfiles 的 hyprland-session.target：hyprland autostart 拉起它，
  # 它 Requires graphical-session.target，进而带起 waybar.service
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland Session Target";
      Requires = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
  };

  # dunst 通知守护进程：不用 services.dunst（它会生成自己的 dunstrc，与部署版冲突），
  # 改为部署 dotfiles 的 dunstrc + 自建 systemd 用户单元（同 waybar / mpd 的做法）。
  systemd.user.services.dunst = {
    Unit = {
      Description = "Dunst notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.dunst}/bin/dunst";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # mpd：对应 dotfiles 里由 systemd 托管的 mpd（Arch 那边是 /usr/bin/mpd）
  systemd.user.services.mpd = {
    Unit = {
      Description = "Music Player Daemon";
      Documentation = "https://www.musicpd.org/";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon --verbose";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # polkit 认证代理：原 hyprland.lua 的 autostart 用 Arch 路径
  # /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1，NixOS 上没有 /usr/lib，
  # 那行一直是死命令。改为自建 systemd 用户单元拉起，ExecStart 走 nix store 路径
  #（同 waybar / mpd / dunst 的做法）。
  systemd.user.services.polkit-gnome-auth-agent = {
    Unit = {
      Description = "polkit-gnome authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
