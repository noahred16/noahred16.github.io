# If .bashrc exists, pull it into this shell session
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Profile settings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


#
# Start ssh-agent if not already running OR if we can't connect to it
if ! ssh-add -l &>/dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# List of keys you want to load
SSH_KEYS=(
    "$HOME/.ssh/xps8300-github"
    # "$HOME/.ssh/forbright"
    # "$HOME/.ssh/cabem"
)

# Add each key if not already loaded
for key in "${SSH_KEYS[@]}"; do
    if [ -f "$key" ] && ! ssh-add -l 2>/dev/null | grep -q "$key"; then
        ssh-add "$key" 2>/dev/null
    fi
done

source /usr/lib/git-core/git-sh-prompt
# 17:27:13 noah-xps8300-kubuntu AlphaPente (main)$ 
# hard code xps8300
# PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\t \[\033[01;33m\]xps8300\[\033[01;34m\] \W\[\033[00m\]\$ "
# user for the prompt noah-smith@noah-xps8300-kubuntu
# PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\t \[\033[01;33m\]\u\[\033[01;34m\] \W\[\033[00m\]\$ "
# system for the prompt - noah-xps8300-kubuntu - (so I can tell if I'm on a different machine)
# PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\t \[\033[01;33m\]\h\[\033[01;34m\] \W\[\033[00m\]\$ "
PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\t \[\033[01;33m\]\h\[\033[01;34m\] \W\[\033[00m\]\[\033[01;35m\]\$(__git_ps1 ' (%s)')\[\033[00m\]\$ "


# Permanent frequently-used commands
PERMA_HISTORY=(
    "cd ~/repos/web_scrape"
    "cd ~/repos/AlphaPente"
    # "fixcode"
    # "fixgit"
    # "error_lsp"
    # "clear_error"
    # "sudo tail /var/log/apache2/error.log"
    # "composer install && pnpm install && sh bin/generate-code.sh"
    # "vendor/bin/phpunit"
    # "vendor/bin/phpcbf"
    # "vendor/bin/doctrine-migrations diff"
    # "vendor/bin/doctrine-migrations migrations:list"
    "git commit --amend --no-edit"
    "git reset --soft HEAD~1"
    "tmux attach -t claude"
    "tmux new -s claude"
    "tmux new -s pente"
    "tmux ls"
    "tmux attach -t pente"
    "cd ~/repos/web_scrape && bash print_output.sh"
    "python -m venv ~/.venvs/py312"
    "source ~/.venvs/py312/bin/activate"
    "pip install --upgrade pip"
    "pip install torch --index-url https://download.pytorch.org/whl/cpu"
    "pip install numpy"
)

for cmd in "${PERMA_HISTORY[@]}"; do
    history -s "$cmd"
done


# Aliases
alias ask='claude -p'
alias python='python3'
alias pip='pip3'
alias gs='git status'
alias f='file=$(fzf); [ -n "$file" ] && code "$file" && echo "Opening $file"'
alias vf='file=$(fzf); [ -n "$file" ] && vim "$file" && echo "Opening $file"'
alias sl='ls'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CFl'
#alias nrsmfb='sshfs -o reconnect cabemns@AWS-Dev-Webapp:/home/cabemns/dev/ /home/noahred16/Forbright/mountDir/dev'
# alias nrsmfb2='sshfs -o reconnect cabemns@AWS-Dev-Webapp:/home/cabemns/sites/llf1/ /home/noahred16/Forbright/mountDir/dev'
# alias nrsmfb='sshfs -o reconnect cabemns@AWS-Dev-Webapp:/home/cabemns/sites/dev/ /home/noahred16/Forbright/mountDir/dev'
# alias gdesktop='cd /mnt/c/Users/NoahSmith/Desktop'
# alias gdownloads='cd /mnt/c/Users/NoahSmith/Downloads'

# handle linux vs windows open
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias open='dolphin'
else
    alias open='explorer.exe'
fi

# # enable programmable completion features (you don't need to enable
# # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# # sources /etc/bash.bashrc).
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion




# MAC
# autoload -Uz vcs_info
# precmd() { vcs_info }
# zstyle ':vcs_info:git:*' formats '%b '
# setopt PROMPT_SUBST

# PROMPT='%F{yellow}[%*]%f %F{cyan}%1d%f %F{green}${vcs_info_msg_0_}%f$ '
# autoload -Uz history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey "^[[A" history-beginning-search-backward-end
# bindkey "^[[B" history-beginning-search-forward-end
