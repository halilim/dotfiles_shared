#!/usr/bin/env bash

# <xbar.title>Network Switcher</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Halil Özgür</xbar.author>
# <xbar.author.github>halilim</xbar.author.github>
# <xbar.desc>Ethernet ↔ Wi-Fi check and switch connection</xbar.desc>
# TODO: Merge Wi-Fi screenshot & link it
# <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>

# <xbar.var>select(VAR_CHECK_METHOD="ping"): Experimental [ping, curl]</xbar.var>
# <xbar.var>string(VAR_CHECK_HOST="1.1.1.1"): Preferably always on and close, so that the happy path is as fast as possible</xbar.var>
# <xbar.var>string(VAR_CHECK_TIMEOUT="3"): After this number of seconds, deem it down</xbar.var>
# <xbar.var>boolean(VAR_DISABLE_AUTO_SWITCH=false): For debugging or connecting to the router</xbar.var>
# <xbar.var>boolean(VAR_SUDO=false): Use sudo for switching (automatically detected)</xbar.var>
# TODO: Track connection status of all networks (e.g. "down since ...")
# <xbar.var>string(VAR_DOWN_SINCE="{}"): (Internal/Private) Data to hold downtimes</xbar.var>

# Alternative ways to combine connections:
# 1. Software: Speedify
# 2. Hardware: Multi-WAN routers

[ -t 0 ] && IS_TTY=1 || IS_TTY='' # If stdin is a terminal (xbar > "Run in terminal"), for debugging
SELF_PATH=$0
ACTION=$1
CONFIG_FILE="$SELF_PATH.vars.json"
self_name=$(basename "$SELF_PATH")
self_name="${self_name%%.*}"
LOG_CONF=/etc/newsyslog.d/xbar."$self_name".conf
LOG_FILE=~/Library/Logs/xbar."$self_name".log
unset self_name

# TODO: Remove after https://github.com/matryer/xbar/issues/914
if [[ -s "$CONFIG_FILE" ]]; then
  config=$(<"$CONFIG_FILE")
  for key in VAR_CHECK_METHOD VAR_CHECK_HOST VAR_CHECK_TIMEOUT VAR_DISABLE_AUTO_SWITCH VAR_SUDO VAR_DOWN_SINCE; do
    line=$(grep "$key" <<<"$config")
    value=$(echo "$line" | cut -d' ' -f2 | tr -d '",')
    [[ $line && ${!key} != "$value" ]] && declare "$key=$value"
  done
  unset config key line value
fi

# --- INIT FUNCTIONS ---
function write_log_conf() {
  if [[ ! -f $LOG_CONF ]]; then
    if can_sudo "writing $LOG_CONF"; then
      # man newsyslog.conf
      echo "$LOG_FILE : 644 1 1024 *" | sudo tee -a "$LOG_CONF" >/dev/null
    fi
  fi
}

function get_networks() {
  # listnetworkserviceorder outputs:
  # An asterisk (*) denotes that a network service is disabled.
  # (*) Service 1
  # (Hardware Port: Service 1, Device: en0)
  #
  # (2) Service 2
  # (Hardware Port: Wi-Fi, Device: en1)
  # ...
  local networks number name display_name name_sep='·' device
  networks=$(networksetup -listnetworkserviceorder | tail -n +2)

  while [ "$networks" != '' ]; do
    networks="${networks#*\(}"  # '*) Service 1\n...'
    number=${networks%%\)*}     # '*'
    networks="${networks#*\) }" # 'Service 1\n...'
    name=${networks%%$'\n'*}    # 'Service 1'
    display_name=$name

    networks="${networks#*$'\n'*Device: }" # 'en0)\n...'
    device=${networks%%\)*}                # 'en0'
    networks="${networks#*\)}"             # '' (tail call for the final network, since there's no \n\n anymore)
    networks="${networks#*$'\n\n'}"        # '(2) Service 2\n...'

    [[ $display_name == *Wi-Fi* ]] && display_name="$display_name $name_sep$(networksetup -getairportnetwork "$device" | cut -d : -f 2)"
    display_name="$display_name $name_sep $device"

    NUMBERS+=("$number")
    NAMES+=("$name")
    DISPLAY_NAMES+=("$display_name")
    DEVICES+=("$device")
  done
}

function get_current_and_next() {
  CURRENT_INDEX=$(get_enabled_index)
  CURRENT_NAME="${NAMES[*]:$CURRENT_INDEX:1}"
  CURRENT_DISPLAY_NAME="${DISPLAY_NAMES[*]:$CURRENT_INDEX:1}"
  CURRENT_DEVICE="${DEVICES[*]:$CURRENT_INDEX:1}"

  NEXT_INDEX=$(get_enabled_index $((CURRENT_INDEX + 1)))
  NEXT_NAME="${NAMES[*]:$NEXT_INDEX:1}"
  NEXT_DISPLAY_NAME="${DISPLAY_NAMES[*]:$NEXT_INDEX:1}"
  NEXT_DEVICE="${DEVICES[*]:$NEXT_INDEX:1}"
}

function get_enabled_index() {
  local i=${1:-0} number device
  for (( ; i < ${#DEVICES[@]}; i++)); do
    number=${NUMBERS[*]:$i:1}
    device=${DEVICES[*]:$i:1}
    if [[ $number != '*' && $device ]]; then
      echo "$i"
      return
    fi
  done
}
# --- END: INIT FUNCTIONS ---

# --- ACTION FUNCTIONS ---
function handle_actions() {
  local do_switch do_refresh manual_switch

  case "$ACTION" in
    switch)
      manual_switch=1
      do_switch=1
      do_refresh=1
      ;;

    *)
      if [[ $VAR_DISABLE_AUTO_SWITCH == false ]] && ! is_connected "$CURRENT_DEVICE" && [[ $NEXT_DEVICE ]]; then
        CURRENT_CONNECTED=false
        log "Current network $CURRENT_DISPLAY_NAME is down"
        do_switch=1
      fi
      ;;
  esac

  if [[ $do_switch ]]; then
    [[ ! $manual_switch ]] && NEXT_CONNECTED=$(is_connected "$NEXT_DEVICE" && echo true || echo false)
    if [[ $manual_switch || $NEXT_CONNECTED == true ]]; then
      log "Switching to $NEXT_DISPLAY_NAME$([[ $VAR_SUDO == true ]] && echo ' with sudo')"
      if ! switch; then
        do_refresh=''
      fi
    else
      log "$NEXT_DISPLAY_NAME is down too, not switching"
      do_refresh=''
    fi
  fi

  [[ $do_refresh ]] && refresh
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
  NAMES[0]=$NEXT_NAME
  NAMES[NEXT_INDEX]=$CURRENT_NAME
  CURRENT_NAME=$NEXT_NAME

  DISPLAY_NAMES[0]=$NEXT_DISPLAY_NAME
  DISPLAY_NAMES[NEXT_INDEX]=$CURRENT_DISPLAY_NAME
  CURRENT_DISPLAY_NAME=$NEXT_DISPLAY_NAME

  DEVICES[0]="$CURRENT_DEVICE"
  DEVICES[CURRENT_INDEX]=$CURRENT_DEVICE
  CURRENT_DEVICE=$NEXT_DEVICE
}

function exec_switch() {
  local do_sudo=$1 cmd=(networksetup -ordernetworkservices "${NAMES[@]}")

  if [[ $do_sudo == true ]]; then
    if can_sudo 'switching networks'; then
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
    local msg=${1:-''}
    [[ $msg ]] && msg=" for: $msg"
    log "Screen is locked, can't sudo$msg" 1
    return 1
  fi
}

function is_connected() {
  local interface=$1

  case "$VAR_CHECK_METHOD" in
    curl)
      curl "$VAR_CHECK_HOST" -Is --connect-timeout "$VAR_CHECK_TIMEOUT" --interface "$interface" >/dev/null
      ;;
    *)
      # ping is adding 1 second somewhere
      ping -c 1 -W $(((VAR_CHECK_TIMEOUT - 1) * 1000)) -b "$interface" "$VAR_CHECK_HOST" >/dev/null
      ;;
  esac
}

function log() {
  local msg=$1 and_echo=${2:-}

  if [[ $IS_TTY || $and_echo ]]; then
    echo >&2 "Log: $msg"
  fi

  if [[ ! $IS_TTY ]]; then
    echo "$(date -Iseconds) $msg" >>"$LOG_FILE"
  fi
}

function refresh() {
  if [[ $IS_TTY ]]; then
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
}
# --- END: UTILS ---

write_log_conf

declare -a NUMBERS NAMES DISPLAY_NAMES DEVICES
get_networks

declare CURRENT_INDEX CURRENT_NAME CURRENT_DISPLAY_NAME CURRENT_DEVICE CURRENT_CONNECTED \
        NEXT_INDEX NEXT_NAME NEXT_DISPLAY_NAME NEXT_DEVICE NEXT_CONNECTED
get_current_and_next

handle_actions

if [[ $CURRENT_CONNECTED == false ]]; then
  printf '.!.'
else
  case $CURRENT_NAME in
    *\ Ethernet | *\ LAN) printf '<·>' ;;
    *Wi-Fi*) printf '.ıl' ;;
    *) printf '···' ;;
  esac
fi

echo ' | size=16'
echo '---'

echo "Connected: $CURRENT_DISPLAY_NAME$([[ $CURRENT_CONNECTED == false ]] && echo ' - NO INTERNET')"

if [[ $NEXT_CONNECTED != false ]]; then
  echo "Switch to: $NEXT_DISPLAY_NAME | bash=$SELF_PATH | param1=switch"
else
  echo "Can't switch to $NEXT_DISPLAY_NAME, it's down too | color=#993333"
fi
# Another shortcut: Click the Wi-Fi icon in the menu bar and hold ⌥ option
echo 'Network Settings | shell=open | param1="x-apple.systempreferences:com.apple.preference.network"'
printf 'Open logs | shell=open | param1="%q"\n' "$LOG_FILE"
