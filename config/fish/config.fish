if status is-interactive
    # Commands to run in interactive sessions can go here

    # Environment setup
    # Apply .profile: use this to put fish compatible .profile stuff in
    # if test -f ~/.fish_profile
    #     source ~/.fish_profile
    # end

    # Enable the fish greeting
    set -g fish_greeting ""

    # Aliases
    if test -f ~/.config/fish/abbrs.fish
        source ~/.config/fish/abbrs.fish
    end

    if command -sq systemctl
        for line in (systemctl --user show-environment)
            set -l kv (string split -m 1 = -- $line)
            if not contains $kv[1] PWD SHLVL _
                set -gx $kv[1] (string trim -c "'\"" -- $kv[2])
            end
        end
    end

    # Enable fastfetch
    # fastfetch

    # The line below is needed to make starship working in the fish shell
    starship init fish | source
end
