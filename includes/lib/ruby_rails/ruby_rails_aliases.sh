# shellcheck disable=SC2139
# Intentionally disabled for the whole file, mostly for RUBY_CMD_PREFIX/RAILS_CMD/RAKE_CMD
# TODO: Replace with block level disables if it gets implemented

alias libra='$EDITOR "$DOTFILES_INCLUDES"/lib/ruby_rails/ruby_rails_aliases.sh'

if [ -n "${ZSH_VERSION:-}" ]; then
  alias -g CNE='-- --with-cflags="-Wno-error=implicit-function-declaration"'
  alias -g DS='DISABLE_SPRING=1'
  alias -g RW0='RUBYOPT="-W0"'
fi

# cSpell:ignore biq bebr beru berua besf bucq
alias bundle_conf='$EDITOR ~/.bundle/config'
alias b='bundle'
alias {biq,bq}='bundle install --quiet'
alias bebr='bundle exec brakeman'
alias bep='bundle exec puma'
alias berk='bundle exec rake'
alias beru='bundle exec rubocop'
alias berua='bundle exec rubocop -a'
alias bes='bundle exec standardrb'
alias besf='bundle exec standardrb --fix'
alias bub='bundle update --bundler'
alias buc='bundle update --conservative'
alias bucq='bundle update --conservative --quiet'
alias bv='bundle --version'

alias fr="fd -E 'config/locales/' -E 'features/' -E 'spec/' -E 'test/' -E '__tests__/'"

alias fs='foreman start'

# cSpell:ignore hrr hrrc hrrr
alias hrr="heroku run rails"
alias hrrc="heroku run rails console"
alias hrrr='heroku run rails runner ""'

# cSpell:ignore mailcatch
alias {mc,mailcatch}='mailcatcher -f'

# Ripgrep
# cSpell:ignore rgr rgrr rgrw
alias rgr="rg -g '!config/locales/' -g '!features/' -g '!spec/' -g '!test/' -g  '!__tests__/'"
alias rgrr="rg -g '*.rb' -g '!features/' -g '!spec/' -g '!test/'"
alias rgrw="rgr -w"

# cSpell:ignore  rpry ramazing
alias rp='ruby -rpry -ramazing_print'
alias rv='ruby -v'

# cSpell:ignore raa rav rcac rgg rgm rgmp rgmo rrz rro rrow rrowe rsl rvv
alias raa="$RAILS_CMD about"
alias rav="$RAILS_CMD -v"
alias rc="$RAILS_CMD console"
alias rce="EDITOR='code --wait' $RAILS_CMD credentials:edit"
alias rcac="rm -rf tmp/cache/{assets,webpacker}/*" # Rails clear asset cache
alias rgg="$RAILS_CMD generate"
alias rgm="$RAILS_CMD generate migration"
alias rgmp="$RAILS_CMD generate migration dummy --pretend"
alias rgmo="$RAILS_CMD generate model"
alias rgs="$RAILS_CMD generate scaffold"
alias rnd="rails new dummy --minimal --skip-active-record --skip-test --skip-git --skip-gemfile"
alias rnv='rails _7.1.0_ new'
alias rr="$RAILS_CMD runner"
alias {rrf,rrz}="$RAILS_CMD routes | fzf"
alias rro="$RAILS_CMD routes"
# sed removes trailing whitespace from `Prefix | `
alias rrow="$RAILS_CMD routes | sed 's/[[:space:]]*$//' > routes.txt"
alias rrowe="$RAILS_CMD routes --expanded | sed 's/[[:space:]]*$//' > routes_expanded.txt"
alias rrp="$RAILS_CMD runner -e production"
alias rrt="$RAILS_CMD runner -e test"
alias rs="$RAILS_CMD server"
alias rsl='rails_serve_lan' # Allow access from LAN (must be in the same network/Wi-Fi etc.)
alias rvv="ruby -v && $RAILS_CMD -v"

# cSpell:ignore rkdc rkdcl rkdct rkdm rkdmdv rkdms rkdmst rkdmt rkdmv rkdr rkdrt rkds rkro rrs gco
alias rk="$RAKE_CMD"
alias rkdc="$RAKE_CMD db:create"
alias rkdcl="$RAKE_CMD db:create db:schema:load"
alias rkdct="$RAKE_CMD db:create RAILS_ENV=test"
alias rkdm="$RAKE_CMD db:migrate"
alias rkdmdv="$RAKE_CMD db:migrate:up VERSION=" # Migrate SPECIFIED version
alias rkdmdv="$RAKE_CMD db:migrate:down VERSION=" # Roll back SPECIFIED version
alias rkdms="$RAKE_CMD db:migrate:status"
alias rkdmst="$RAKE_CMD db:migrate:status RAILS_ENV=test"
alias rkdmt="$RAKE_CMD db:migrate RAILS_ENV=test"
alias rkdmv="$RAKE_CMD db:migrate VERSION=" # Migrate up/down UNTIL version
alias rkdr="$RAKE_CMD db:rollback"
alias rkdrt="$RAKE_CMD db:rollback RAILS_ENV=test"
alias rkds="$RAKE_CMD db:seed"
alias rkro="$RAKE_CMD routes"
alias rkT="$RAKE_CMD -T"
alias rrs="gco db/schema.rb && $RAKE_CMD db:drop db:create db:schema:load db:migrate"

# cSpell:ignore sfd
alias s="${RUBY_CMD_PREFIX}rspec"
alias ss="${RUBY_CMD_PREFIX}rspec --seed"
alias {rsb,rst,sb,st}="${RUBY_CMD_PREFIX}rspec --backtrace" # Replaces `rails server --bind` from oh-my-zsh Rails plugin
alias {rfd,sfd}="${RUBY_CMD_PREFIX}rspec --format documentation"

# cSpell:ignore nosp spk spst spp spps spsr
# Not using `spring stop/status` etc., because they miss zombie processes and are slow
alias {nosp,spd}='DISABLE_SPRING=1'
alias {spk,spst}='kill_spring'
alias {spg,spp,spps,sps}='psg spring'
alias spsr="${RUBY_CMD_PREFIX}spring server"

alias sq="${RUBY_CMD_PREFIX}sidekiq"

# cSpell:ignore testrb
alias testrb='$EDITOR ~/Desktop/test\ code/test.rb'
