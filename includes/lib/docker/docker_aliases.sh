alias libda='$EDITOR "$DOTFILES_INCLUDES"/lib/docker/docker_aliases.sh' # cSpell:ignore libda

alias acts='docker run --rm -it catthehacker/ubuntu:act-latest bash' # cSpell:ignore catthehacker

# cSpell:ignore dkcl dkcs dkcst dkei dkeis dkirm dkin dkins dkst dkri dkrm dkrr dkrri
alias dk='docker'
alias dkb='docker build'
alias dkc='docker container'
# shellcheck disable=SC2139
alias {dkcl,dkl}='docker container ls'
alias dkcs='docker container start'
alias dkcst='docker container stop'
alias dke='docker exec'
alias dkei='docker exec -it'
alias dkeis='docker exec -it ... bash'
alias dkirm='docker images rm'
alias dkin='docker info'
alias dkins='docker inspect'
alias dkk='docker kill'
alias dkst='docker stop'
alias dkr='docker run'
alias dkri='docker run -it'
alias dkrm='docker rm'
alias dkrr='docker run --rm'
alias dkrri='docker run --rm -it'
alias dks='docker stats --no-stream'
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'"

# cSpell:ignore dceis dcos dcrr
# shellcheck disable=SC2139
alias {dceis,dcs}='docker compose exec -it ... sh'
alias dcos='docker compose stats'
alias dcp="docker compose ps --format 'table {{.Name}}\t{{.Status}}'"
alias dcrr='dcr --rm'
