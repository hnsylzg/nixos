# aliases
alias ls='ls --group-directories-first --color=auto'
alias ll='ls -lh --group-directories-first'
alias la='ls -a --group-directories-first'
alias lla='ls -lah --group-directories-first'

#git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# abbrs
#unlock the pacman database 
abbr -a unlock 'sudo rm /var/lib/pacman/db.lck'

# Cleanup orphaned packages
abbr -a cleanup 'pacman -Qtdq | sudo pacman -Rsn -'

# Cleanup pacman cache 
abbr -a cleancache 'sudo rm -rf /var/cache/pacman/pkg/*'

# Get the error messages from journalctl
abbr -a jctl "journalctl -p 3 -xb"

# Recent installed packages
abbr -a rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

#shrink disk
abbr -a shrink 'sudo vmware-toolbox-cmd disk shrink /'
