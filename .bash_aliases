# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias ll='ls -l --color=auto'

alias exe="tmux detach-client -s exe; tmux attach -t exe"
alias myR="tmux detach-client -s R; tmux attach -t R"
alias script="tmux detach-client -s script; tmux attach -t script"
alias rand="tmux detach-client -s rand; tmux attach -t rand"
alias ..="cd .."




