#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'

# TODO: Convert into a generic network auto-switcher. Prefer for more than two networks, and multiple wi-fis?

# <xbar.title>Network Switcher</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Halil Özgür</xbar.author>
# <xbar.author.github>halilim</xbar.author.github>
# <xbar.desc>Auto-switch networks when one is down (e.g. LAN ↔ Wi-Fi)</xbar.desc>
# TODO: Merge Wi-Fi screenshot & link it
# <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>

# TODO: Fails with exit status 4 etc., e.g. when rebooting the router
# TODO: Another host or different method? 1.1.1.1 issues are rare but noticeable at /5s.
#        Maybe fallback hosts? E.g. convert VAR_TEST_HOST to an array of hosts, separate by comma
#        Pro: less chance of false negatives, Con: slower (n*500ms+)
#        Risk: connect to the other network for a (hopefully) short while. Seems acceptable
#        Add a note about the reason for not adding a fallback
# Test host: use something always on and close to you, so that the happy path is as fast as possible.
# <xbar.var>string(VAR_TEST_HOST="1.1.1.1"): Host to check connection against</xbar.var>
# <xbar.var>string(VAR_PREFER_DEVICE=""): Prefer this if both are connected</xbar.var>
# <xbar.var>boolean(VAR_PREFER_ENABLED=false): Toggle device preference (e.g. for manual switching)</xbar.var>

# Alternative ways to combine connections:
# 1. Software: Speedify
# 2. Hardware: Multi-WAN routers

CONFIG_FILE="$0.vars.json"

# Remove after https://github.com/matryer/xbar/issues/914
CONFIG=$(< "$CONFIG_FILE")
function get_config() {
  local key=$1 line
  line=$(grep "$key" <<< "$CONFIG")
  if [[ $line ]]; then
    echo "$line" | cut -d' ' -f2 | tr -d '",'
  else
    return 0
  fi
}
VAR_TEST_HOST=$(get_config 'VAR_TEST_HOST')
VAR_PREFER_ENABLED=$(get_config 'VAR_PREFER_ENABLED')
VAR_PREFER_DEVICE=$(get_config 'VAR_PREFER_DEVICE')
# TODO: Add option to disable auto-switch

[ -t 0 ] && IS_TTY=1 || IS_TTY='' # If stdin is a terminal (TTY, "Run in terminal"), for debugging

SCRIPT_NAME=$(basename "$0")
LOG_FILE=~/Library/Logs/xbar.$SCRIPT_NAME.log
LOG_CONF=/etc/newsyslog.d/$SCRIPT_NAME.conf
if [[ ! -f $LOG_CONF ]]; then
  # man newsyslog.conf
  echo "$LOG_FILE : 644 1 1024 *" | sudo tee -a "$LOG_CONF" > /dev/null
fi
LOG_ARR=()

function get_networks() {
  # listnetworkserviceorder outputs:
  # An asterisk (*) denotes that a network service is disabled.
  # (*) Service 1
  # (Hardware Port: Service 1, Device: en0)
  #
  # (2) Service 2
  # (Hardware Port: Wi-Fi, Device: en1)
  # ...
  local networks number name device
  networks=$(networksetup -listnetworkserviceorder | tail -n +2)

  while [ "$networks" != '' ]; do
    networks="${networks#*\(}" # '*) Service 1\n...'
    number=${networks%%\)*} # '*'
    networks="${networks#*\) }" # 'Service 1\n...'
    name=${networks%%$'\n'*} # 'Service 1'

    networks="${networks#*$'\n'*Device: }" # 'en0)\n...'
    device=${networks%%\)*} # 'en0'
    networks="${networks#*\)}" # '' (tail call for the final network, since there's no \n\n anymore)
    networks="${networks#*$'\n\n'}" # '(2) Service 2\n...'

    numbers+=("$number")
    names+=("$name")
    devices+=("$device")
  done
}

function get_enabled_index() {
  local i=${1:-0}
  for (( ; i < ${#devices[@]}; i++)); do
    number=${numbers[*]:$i:1}
    device=${devices[*]:$i:1}
    if [[ $number != '*' && $device ]]; then
      echo "$i"
      return
    fi
  done
}

function is_connected() {
  local device=$1 host=${VAR_TEST_HOST:-'1.1.1.1'}
  curl "$host" -Is --connect-timeout 1 --interface "$device" > /dev/null 2>&1
}

function log() {
  if [[ ${#LOG_ARR[@]} -gt 0 ]]; then
    function join_array() {
      local delim=$1 arr=$2
      shift 2
      printf %s "${arr[*]}${*/#/$delim}"
    }
    local log_str
    log_str=$(join_array '. ' "${LOG_ARR[@]}")

    if [[ $IS_TTY ]]; then
      echo "Log: $log_str"
    else
      echo "$(date -Iseconds) $log_str" >> "$LOG_FILE"
    fi
  fi
}

function toggle_prefer() {
  local name=VAR_PREFER_ENABLED current_value=$VAR_PREFER_ENABLED new_value=${1:-}
  if [[ ! $new_value ]]; then
    new_value=$([[ $current_value == true ]] && echo false || echo true)
  fi

  [[ $new_value == "$current_value" ]] && return

  LOG_ARR+=("Setting config $name to $new_value")
  sed -i '' -E "s/(\"$name\": )[[:alpha:]]*/\1$new_value/" "$CONFIG_FILE"
}

action=$1

numbers=()
names=()
devices=()
get_networks

# TODO: Track connection status of all networks (e.g. "down since ...")

current_index=$(get_enabled_index)
current_device="${devices[*]:$current_index:1}"
current_name="${names[*]:$current_index:1}"

next_index=$(get_enabled_index $((current_index + 1)))
next_name="${names[*]:$next_index:1}"
next_device="${devices[*]:$next_index:1}"

prefer_index=''
if [[ $VAR_PREFER_DEVICE ]]; then
  for i in "${!devices[@]}"; do
    if [[ "${devices[$i]}" = "$VAR_PREFER_DEVICE" ]]; then
      prefer_index=$i
      break
    fi
  done
  prefer_name="${names[*]:$prefer_index:1}"
fi

do_switch=''
do_refresh=''
refresh_sleep=2
manual_switch=''

case "$action" in
  switch)
    manual_switch=1
    do_switch=1
    do_refresh=1
    ;;

  toggle_prefer)
    toggle_prefer
    refresh_sleep=0
    do_refresh=1
    ;;

  *)
    if ! is_connected "$current_device" && [[ $next_device ]]; then
      LOG_ARR+=("Current network $current_name ($current_device) is down")
      do_switch=1

    elif [[ $VAR_PREFER_ENABLED == 'true' && $VAR_PREFER_DEVICE && $current_device != "$VAR_PREFER_DEVICE" ]] && is_connected "$VAR_PREFER_DEVICE"; then
      LOG_ARR+=("Preferred network is back/on")
      next_index=$prefer_index
      next_name=$prefer_name
      next_device="$VAR_PREFER_DEVICE"
      do_switch=1

    fi
    ;;
esac

if [[ $do_switch ]]; then
  # TODO: Manual (force) mode shouldn't check if it's connected - check else too
  if is_connected "$next_device"; then
    # Otherwise, it would switch right back to the preferred network on the next refresh
    [[ $manual_switch && $VAR_PREFER_ENABLED == 'true' && $VAR_PREFER_DEVICE == "$current_device" ]] && toggle_prefer false

    LOG_ARR+=("Switching to $next_name ($next_device)")

    names[0]=$next_name
    names[next_index]=$current_name
    current_name=$next_name

    devices[0]="$current_device"
    devices[current_index]=$current_device
    current_device=$next_device

    networksetup -ordernetworkservices "${names[@]}"
  else
    LOG_ARR+=("$([[ $manual_switch ]] && echo 'Manual switch: ')Next network $next_name ($next_device) is down, not switching")
    do_refresh=''
  fi
fi

if [[ $do_refresh ]]; then
  if [[ $IS_TTY ]]; then
    echo '(will refresh)'
  else
    sleep "$refresh_sleep"
    # TODO: Remove and add ` | refresh=true` to the switch & prefer after https://github.com/matryer/xbar/issues/914
    open -g "xbar://app.xbarapp.com/refreshPlugin?path=$0"
    log
    exit
  fi
fi

log

case $current_name in
  *\ LAN | *\ ethernet) printf '<·>' ;;
  *Wi-Fi) printf '.ıl' ;;
  *) printf '···' ;;
esac

echo ' | size=16'
echo '---'

echo "Connected to $current_name ($current_device)"

switch_text="Switch to $next_name ($next_device)"
if [[ $VAR_PREFER_ENABLED == 'true' && $VAR_PREFER_DEVICE == "$current_device" ]]; then
  switch_text+=" & un-prefer $prefer_name ($VAR_PREFER_DEVICE)"
fi
echo "$switch_text | bash=$0 | param1=switch"

if [[ $VAR_PREFER_DEVICE ]]; then
  if [[ $VAR_PREFER_ENABLED == 'true' ]]; then
    echo "Un-prefer $prefer_name ($VAR_PREFER_DEVICE) | bash=$0 | param1=toggle_prefer"
  else
    # TODO: Add & connect to ...(here & in action)
    echo "Prefer $prefer_name ($VAR_PREFER_DEVICE) | bash=$0 | param1=toggle_prefer"
  fi
fi

# Another shortcut: Click the Wi-Fi icon in the menu bar and hold ⌥ option
echo 'Network Settings | shell=open | param1="x-apple.systempreferences:com.apple.preference.network"'
echo "Open logs | shell=open | param1=""$LOG_FILE"""
echo "VAR_PREFER_DEVICE=\"$VAR_PREFER_DEVICE\" VAR_PREFER_ENABLED=\"$VAR_PREFER_ENABLED\""
