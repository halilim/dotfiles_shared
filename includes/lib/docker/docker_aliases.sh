alias libda='$EDITOR "$DOTFILES_INCLUDES"/lib/docker/docker_aliases.sh' # cSpell:ignore libda

alias acts='docker run --rm -it catthehacker/ubuntu:act-latest bash' # cSpell:ignore catthehacker

# cSpell:ignore dkcl dkcs dkcst dkee dkenv dkei dkeis dkil dkip dkirm dkin dkins dkst dkri dkrm dkrr dkrri dkps
alias dk='docker'
alias dkb='docker build'
alias dkc='docker container'
# shellcheck disable=SC2139
alias {dkcl,dkl}='docker container ls'
alias dkcs='docker container start'
alias dkcst='docker container stop'
alias dke='docker exec'
# shellcheck disable=SC2139
alias {dkee,dkenv}='docker exec ... env'
alias dkei='docker exec -it'
alias dkeis='docker exec -it ... bash'
alias dkil='docker image ls'
alias dkip='docker image pull'
alias dkirm='docker image rm'
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
alias dkps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'"

# cSpell:ignore dceis dclf dcos dcre dcrr
alias dce='docker compose exec'
# shellcheck disable=SC2139
alias {dceis,dcs}='docker compose exec -it ... sh'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dco='docker compose' # dc is a system command
alias dcos='docker compose stats'
alias dcp="docker compose ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}'"
alias dcre='docker compose restart'
alias dcr='docker compose run'
alias dcrr='docker compose run --rm'
alias dcu='docker compose up -d'
