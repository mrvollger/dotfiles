#!/bin/sh

startDir=$HOME/

if [ $1 == '1' ]; then
    S="script"
    cmd='cd '
    cmd='uptime' #'ssh -A ocelot'
elif [ $1 == '2' ]; then
    echo 'exe'
    S="exe"
    cmd='uptime' #'ssh -A ocelot'
elif [ $1 == '3' ]; then
  echo 'R'
  S='R'
  cmd='uptime' #'ssh -A ocelot'
else
    S='rand'
fi


# create session with a window called 1 in a detached state
tmux new -s $S -n one -d

# select the window I want to run stuff in , session S window 0
tmux select-window -t "$S":1
# I can them exacute a command in that session like this, C-m acts like a carrige return 
tmux send-keys -t $S:1 "${cmd}" C-m "cd $startDir" C-m

# add new windos and do the same 
tmux new-window  -t "$S":2 -n two 
tmux send-keys -t $S:2 "${cmd}" C-m "cd $startDir" C-m

# add new windos and do the same 
tmux new-window  -t "$S":3 -n three 
tmux send-keys -t $S:3 "${cmd}" C-m "cd $startDir" C-m




tmux select-window -t "$S":0
# attach the tmux session
tmux attach -t $S


