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

alias ..="cd .."

alias scancel_batch='scancel $(squeue -u $(whoami) | grep -P -v "interactive|JOBID|n3333"  | awk "{print \$1}")'

if hash eza 2>/dev/null; then
    #alias ls='eza' # alias of ls is dangerous in some situations imo
    alias l='eza -l --group-directories-first --git'
    alias ll='eza -l --group-directories-first --git'
    alias lt='eza -T --git-ignore --level=2 --group-directories-first'
    alias llt='eza -lT --git-ignore --level=2 --group-directories-first'
    alias lT='eza -T --git-ignore --level=4 --group-directories-first'
elif hash lsd 2>/dev/null; then
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
    alias ll='ls -l --color=auto'
else
    alias l='ls -lah'
    alias ll='ls -alF'
    alias la='ls -A'
fi


if hash bat 2>/dev/null; then
  alias cat='bat -pp'
fi

if hash lvim 2>/dev/null; then
  alias vim='lvim'
elif hash nvim 2>/dev/null; then
  alias vim='nvim'
fi

#if hash bgzip 2>/dev/null; then
  #alias zcat='bgzip -cd -@ 8'
  #alias gzip='bgzip -@ 8'
#fi


alias exe="tmux detach-client -s exe; tmux attach -t exe"
alias myR="tmux detach-client -s R; tmux attach -t R"
alias script="tmux detach-client -s script; tmux attach -t script"
alias rand="tmux detach-client -s rand; tmux attach -t rand"

alias parallel="parallel --will-cite"
alias cdr='cd $(readlink -f .)'
alias mailme='history 1 | mail -s "command done" $USER@uw.edu'
alias dup="ls -d */ | parallel -n 1 -j 20 --will-cite du -sh"

alias tv='tidy-viewer'
alias ttv=$'tidy-viewer -s "\t"'


alias rawq=$'squeue -o \'%A;%u;%C;%m;%a;%M;%p;%T;%r;%j;%N;%g;%k;%L;%P\' --noconvert'
alias myq="rawq -u $(whoami) | tv -s ';' -f -u 75"
alias smkjobs="rawq -u $(whoami) | hck -d ';' -F USER -F CPUS -F MIN_MEMORY -F ACCOUNT  -F STATE -F COMMENT | sed 's/_wildcards_.*//g' | sort -r | datamash groupby -H 1,2,3,4,5,6 count 1 | ttv -u 75"




