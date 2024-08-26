#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# NOTE: Although this is marked as Bash, keep it compatible with Zsh & sh (system Bash, 3.2) too

# <xbar.title>Network Switcher</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Halil Özgür</xbar.author>
# <xbar.author.github>halilim</xbar.author.github>
# <xbar.desc>Ethernet ↔ Wi-Fi check & switch. Order networks in System Settings > Network per your preference first. Only the first two will be used.</xbar.desc>
# TODO: Merge Wi-Fi screenshot & link it
# <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>

# NOTE: Keep variables in sync with init_config
# <xbar.var>select(VAR_CHECK_METHOD="ping"): Experimental [ping, curl]</xbar.var>
# <xbar.var>string(VAR_CHECK_HOST="1.1.1.1"): Preferably always on and close, so that the happy path is as fast as possible</xbar.var>
# <xbar.var>string(VAR_CHECK_TIMEOUT="3"): After this number of seconds, deem it down</xbar.var>
# <xbar.var>boolean(VAR_DISABLE_AUTO_SWITCH=false): For debugging or connecting to the router</xbar.var>
# <xbar.var>boolean(VAR_SUDO=false): Use sudo for switching (automatically detected)</xbar.var>
# TODO: Track connection status of all networks (e.g. "down since ...") without any dependency like jq
# <xbar.var>string(VAR_DOWN_SINCE=""): (Internal/Private) Data to hold downtimes</xbar.var>

# Alternative ways to combine connections:
# 1. Software: Speedify
# 2. Hardware: Multi-WAN routers

# --- INIT FUNCTIONS ---

function init_config() {
  # TODO: Enable after https://github.com/matryer/xbar/issues/914
  # if [[ $IS_TTY == false ]]; then
  #   return 0
  # fi

  local var_names defaults config='' name line value

  var_names=(VAR_CHECK_METHOD VAR_CHECK_HOST  VAR_CHECK_TIMEOUT VAR_DISABLE_AUTO_SWITCH VAR_SUDO  VAR_DOWN_SINCE)
  defaults=( ping             1.1.1.1         3                 false                   false     '')

  if [[ -s "$CONFIG_FILE" ]]; then
    config=$(< "$CONFIG_FILE")
  fi

  local i=0
  for (( ; i < ${#var_names[@]}; i++)); do
    name=${var_names[*]:$i:1}

    if [[ $config ]] && line=$(grep "$name" <<< "$config"); then
      value=$(echo "$line" | cut -d' ' -f2 | tr -d '",')
    else
      value=${defaults[*]:$i:1}
    fi

    export "$name"="$value"
  done
}

function write_log_conf() {
  if [[ ! -f $LOG_CONF ]]; then
    local output
    if output=$(can_sudo); then
      # man newsyslog.conf
      echo "$LOG_FILE : 644 1 1024 *" | sudo tee -a "$LOG_CONF" > /dev/null
    else
      log "Couldn't write $LOG_CONF: $output"
    fi
  fi
}

function set_data() {
  # listnetworkserviceorder outputs:
  # An asterisk (*) denotes that a network service is disabled.
  # (*) Service 1
  # (Hardware Port: Service 1, Device: en0)
  #
  # (2) Service 2
  # (Hardware Port: Wi-Fi, Device: en1)
  # ...
  local index networks number name display_name name_sep='·' device connection_status wifi_name

  if [ -n "${ZSH_VERSION:-}" ]; then
    index=1
  else
    index=0
  fi

  networks=$(networksetup -listnetworkserviceorder | tail -n +2)

  while [ "$networks" != '' ]; do
    networks="${networks#*\(}"  # '*) Service 1\n...'
    number=${networks%%\)*}     # '*'
    networks="${networks#*\) }" # 'Service 1\n...'
    name=${networks%%$'\n'*}    # 'Service 1'
    connection_status=''

    networks="${networks#*$'\n'*Device: }" # 'en0)\n...'
    device=${networks%%\)*}                # 'en0'
    networks="${networks#*\)}"             # '' (tail call for the final network, since there's no \n\n anymore)
    networks="${networks#*$'\n\n'}"        # '(2) Service 2\n...'

    display_name="$name $name_sep $device"

    # We keep track of all networks, since ordernetworkservices requires all
    # But only really care about the first two enabled ones
    if [[ $number != '*' && $device && ( ! $CURRENT_INDEX || ! $NEXT_INDEX ) ]]; then
      if is_connected "$device"; then
        connection_status=true
      else
        connection_status=false
      fi

      if [[ $display_name == *Wi-Fi* ]]; then
        if wifi_name=$(networksetup -getairportnetwork "$device") && [[ $wifi_name != *'not associated'* ]]; then
          wifi_name=$(echo "$wifi_name" | cut -d : -f 2)
          wifi_name="${wifi_name#"${wifi_name%%[![:space:]]*}"}"
        else
          connection_status=false
          if [[ $wifi_name == *'power is currently off'* ]]; then
            wifi_name='Off'
          else
            wifi_name='Not Associated'
          fi
        fi

        display_name="$display_name $name_sep $wifi_name"
      fi

      display_name="$display_name $([[ $connection_status == true ]] && echo '✓' || echo '✗')"

      if [[ ! $CURRENT_INDEX ]]; then
        CURRENT_INDEX=$index
        CURRENT_NAME=$name
        CURRENT_DISPLAY_NAME=$display_name
        CURRENT_DEVICE=$device
        CURRENT_CONNECTED=$connection_status
      elif [[ ! $NEXT_INDEX ]]; then
        NEXT_INDEX=$index
        NEXT_NAME=$name
        NEXT_DISPLAY_NAME=$display_name
        NEXT_DEVICE=$device
        NEXT_CONNECTED=$connection_status
      fi
    fi

    NUMBERS+=("$number")
    NAMES+=("$name")
    DISPLAY_NAMES+=("$display_name")
    DEVICES+=("$device")
    CONNECTION_STATUSES+=("$connection_status")

    index=$((index + 1))
  done
}

# --- END: INIT FUNCTIONS ---

# --- ACTION FUNCTIONS ---

function handle_actions() {
  local do_switch=false do_refresh=false manual_switch=false

  case "$ACTION" in
    switch)
      manual_switch=true
      do_switch=true
      do_refresh=true
      ;;

    *)
      if [[ $VAR_DISABLE_AUTO_SWITCH == false && $CURRENT_CONNECTED == false && $NEXT_DEVICE ]]; then
        log "Current network $CURRENT_DISPLAY_NAME is down"
        do_switch=true
      fi
      ;;
  esac

  if [[ $do_switch == true ]]; then
    if [[ $manual_switch == true || $NEXT_CONNECTED == true ]]; then
      log "Switching to $NEXT_DISPLAY_NAME$([[ $VAR_SUDO == true ]] && echo ' with sudo')"
      if ! switch; then
        do_refresh=false
        swap_networks # Revert swap, otherwise the current execution will display next as current
      fi
    else
      log "$NEXT_DISPLAY_NAME is down too, not switching"
      do_refresh=false
    fi
  fi

  if [[ $do_refresh == true ]]; then
    refresh
  fi
}

function switch() {
  swap_networks

  local output status
  output=$(exec_switch "$VAR_SUDO" 2>&1)
  status=$?

  if [[ $status != 0 && $output == *'requires admin'* && $VAR_SUDO != 'true' ]]; then
    set_config VAR_SUDO true # If this happens once, it probably happens all the time on this system
    output=$(exec_switch true 2>&1)
    status=$?
  fi

  if [[ $status != 0 ]]; then
    log "Couldn't switch networks: ($status) $output"
  fi

  return $status
}

function swap_networks() {
  NAMES[CURRENT_INDEX]=$NEXT_NAME
  NAMES[NEXT_INDEX]=$CURRENT_NAME
  CURRENT_NAME=$NEXT_NAME

  DISPLAY_NAMES[CURRENT_INDEX]=$NEXT_DISPLAY_NAME
  DISPLAY_NAMES[NEXT_INDEX]=$CURRENT_DISPLAY_NAME
  CURRENT_DISPLAY_NAME=$NEXT_DISPLAY_NAME

  DEVICES[CURRENT_INDEX]="$CURRENT_DEVICE"
  DEVICES[CURRENT_INDEX]=$CURRENT_DEVICE
  CURRENT_DEVICE=$NEXT_DEVICE

  CONNECTION_STATUSES[CURRENT_INDEX]=$NEXT_CONNECTED
  CONNECTION_STATUSES[NEXT_INDEX]=$CURRENT_CONNECTED
  CURRENT_CONNECTED=$NEXT_CONNECTED

  local temp_index=$CURRENT_INDEX
  CURRENT_INDEX=$NEXT_INDEX
  NEXT_INDEX=$temp_index
}

function exec_switch() {
  local do_sudo=$1 cmd=(networksetup -ordernetworkservices "${NAMES[@]}")

  if [[ $do_sudo == true ]]; then
    if can_sudo; then
      sudo "${cmd[@]}"
    else
      return
    fi
  else
    "${cmd[@]}"
  fi
}

# --- END: ACTION FUNCTIONS ---

# --- UTILS ---

function can_sudo() {
  if [[ $(ioreg -n Root -d1 -a | plutil -extract IOConsoleLocked raw -) == true ]]; then
    echo >&2 "Can't sudo: screen is locked"
    return 1
  fi
}

function is_connected() {
  local interface=$1

  case "$VAR_CHECK_METHOD" in
    curl)
      curl "$VAR_CHECK_HOST" -Is --connect-timeout "$VAR_CHECK_TIMEOUT" --interface "$interface" > /dev/null
      ;;
    *)
      # ping is adding 1 second somewhere
      ping -c 1 -W $(((VAR_CHECK_TIMEOUT - 1) * 1000)) -b "$interface" "$VAR_CHECK_HOST" > /dev/null
      ;;
  esac
}

function log() {
  local msg
  msg="$(date -Iseconds) $1"

  if [[ $IS_TTY == true  ]]; then
    echo >&2 "$msg"
  else
    echo "$msg" >> "$LOG_FILE"
  fi
}

function refresh() {
  if [[ $IS_TTY == true ]]; then
    echo '(will refresh)'
  else
    sleep 2
    # TODO: Remove and add ` | refresh=true` to `switch` after https://github.com/matryer/xbar/issues/914
    open -g "xbar://app.xbarapp.com/refreshPlugin?path=$SELF_PATH"
    exit
  fi
}

function set_config() {
  local name=$1 value=$2
  log "Setting config $name to $value"
  sed -i '' -E "s/(\"$name\": \"?)[[:alpha:]]*(\"?)/\1$value\2/" "$CONFIG_FILE"
  export "$name"="$value"
}

# --- END: UTILS ---

[ -t 0 ] && IS_TTY=true || IS_TTY=false # If stdin is a terminal (xbar > "Run in terminal"), for debugging
SELF_PATH=$0
ACTION=${1:-}
CONFIG_FILE="$SELF_PATH.vars.json"
self_name=$(basename "$SELF_PATH")
self_name="${self_name%%.*}"
LOG_CONF=/etc/newsyslog.d/xbar."$self_name".conf
LOG_FILE=~/Library/Logs/xbar."$self_name".log
unset self_name

declare -a NUMBERS NAMES DISPLAY_NAMES DEVICES CONNECTION_STATUSES

declare \
  CURRENT_INDEX='' CURRENT_NAME  CURRENT_DISPLAY_NAME CURRENT_DEVICE CURRENT_CONNECTED \
  NEXT_INDEX=''    NEXT_NAME     NEXT_DISPLAY_NAME    NEXT_DEVICE    NEXT_CONNECTED

init_config
write_log_conf
set_data
handle_actions

if [[ $CURRENT_CONNECTED == true ]]; then
  case $CURRENT_NAME in
    *\ Ethernet | *\ LAN) printf '<·>' ;;
    *Wi-Fi*) printf '.ıl' ;;
    *) printf '···' ;;
  esac
else
  case $CURRENT_NAME in
    *\ Ethernet | *\ LAN) printf '<!>' ;;
    *Wi-Fi*) printf '.ı!' ;;
    *) printf '·!·' ;;
  esac
fi

echo ' | size=16'
echo '---'

echo "Connected: $CURRENT_DISPLAY_NAME$([[ $CURRENT_CONNECTED == false ]] && echo ' | color=#663333')"
echo "Switch to: $NEXT_DISPLAY_NAME$([[ $NEXT_CONNECTED == false ]] && echo ' | color=#993333') | bash=$SELF_PATH | param1=switch"
# Another shortcut: Click the Wi-Fi icon in the menu bar and hold ⌥ option
echo 'Network Settings | shell=open | param1="x-apple.systempreferences:com.apple.preference.network"'
printf 'Open logs | shell=open | param1="%q"\n' "$LOG_FILE"
