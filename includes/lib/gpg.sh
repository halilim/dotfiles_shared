
# See also: omz.zsh > gpg-agent
if [[ $- == *i* ]]; then
  export GPG_TTY=$TTY
fi

alias libgpg='$EDITOR "$DOTFILES_INCLUDES"/lib/gpg.sh' # cSpell:ignore libgpg

# shellcheck disable=SC2139
alias gpg_edit="gpg --edit-key $GPG_KEY" # adduid > enter details > save
# shellcheck disable=SC2139
alias gpg_show_public_key="gpg --armor --export $GPG_KEY"
# Password: iterm2 > cmd-alt-f > password, secret, etc. backup gpg
alias gpg_encrypt='gpg -c --cipher-algo AES256 -o' # ... "$encrypted_file" "$file"
alias gpg_decrypt='gpg --decrypt -o' # ... "$file" "$encrypted_file"

function gpg_check_key() {
  local expiry_date expiry_seconds now remaining_days

  expiry_date=$(gpg --list-key "$GPG_KEY" | rg 'pub.*expires: (.*)\]' -r '$1')
  expiry_seconds=$("$GNU_DATE" -d"$expiry_date" +%s)

  now=$(date +%s)
  remaining_days=$(( (expiry_seconds - now) / 86400 ))

  if [[ $remaining_days -lt 40 ]]; then
    echo "WARNING! GPG key expires in $remaining_days days"
  fi
}

function gpg_email_add() {
  # shellcheck disable=SC2016
  echo '1. `adduid`
2. `save` '
  gpg_edit
}
alias gpg_add_email='gpg_email_add'

function gpg_email_delete() {
  # shellcheck disable=SC2016
  echo 'https://crypto.stackexchange.com/a/9467/25594
1. Select uid: `uid 1`
2. `deluid`
3. `save`'
  gpg_edit
}
# shellcheck disable=SC2139
alias {gpg_delete_email,gpg_remove_email}='gpg_email_delete'

function gpg_send_key() {
  # loop over key servers
  for server in keys.openpgp.org \
                keyserver.ubuntu.com \
                pgp.mit.edu; do
    echo_eval 'gpg --keyserver %q --send-keys %q' "$server" "$GPG_KEY"
  done
}
alias gpg_push_key='gpg_send_key'
