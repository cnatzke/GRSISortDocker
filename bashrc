## .bashrc/.zshrc

# Ignore Case for <tab> completion
bind "set completion-ignore-case on"

# Colour settings
alias ls="ls -v --color=always --group-directories-first"
alias grep="grep --color=auto"
export PYTHONSTARTUP=$HOME/.pythonrc.py 

# Aliases for ease of use
alias c='clear'
alias q='exit'
alias bashrc='vim /home/cnatzke/.bashrc'
alias srcBash='source /home/cnatzke/.bashrc'
alias rt='root -l'

PS1='\e[38;5;241m(\u@\h):\w\n\[\e[0m\]--> '

#export PS1='[\t] \e[91m\u\e[0m@\e[34m\h \e[36m\w \e[0m$ \'
#export PROMPT='[%*] %F{red}%n%f@%F{blue}%m%f %F{yellow}%3~%f $ '
