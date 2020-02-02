#!/bin/bash
default_basepath="$HOME"
default_gamedir_name="main"

hl="\e[95m"
ehl="\e[91m\e[1m"
shl="\e[92m\e[1m"
bhl="$hl\e[1m"
rs="\e[0m"

greet () {
  echo -e ""
  echo -e "                    ${bhl}---_____"
  echo -e "                   /  _____ -----__"
  echo -e "                  / /      -----   /"
  echo -e "                 / /   _        / /${rs}"
  echo -e "__     __  ____     ${bhl}_ / \\ _${rs}    ____"
  echo -e "\\ \\   / / / __ \\   ${bhl}/ -___- \\ ${rs} | ___|"
  echo -e " \\ \\ / / / /  \\/  ${bhl}_- / _ \\ -_${rs} | |__        ___  ___   _   ___"
  echo -e "  \\   / | |  ___ ${bhl}|_ | |_| | _|${rs}| ___| /\\   |   \\|   \\ | | / __\\   /\\"
  echo -e "   | |  | | |__ |  ${bhl}/ \\___/ \\ ${rs} | |   /  \\  | D /| D / | || /     /  \\"
  echo -e "   | |   \\ \\__/ /  ${bhl}\\_-   -_/${rs}  | |  / __ \\ | D \\| | \\ | || \\__  / __ \\"
  echo -e "   |_|    \\____/      ${bhl}\\_/${rs}     |_| /_/  \\_\\|___/|_|\\_\\|_| \\___//_/  \\_\\"
  echo -e "            ${bhl}/ /            / /"
  echo -e "           /  -----____   / /"
  echo -e "            --_____    --- /"
  echo -e "                   -----___${rs}"
  echo -e ""
  echo -e ""
  echo -e "You are about to install ${bhl}YGOFabrica${rs}!"
  echo -e "Do you wish to continue? (Y/n)"
  local answer=""
  read answer
  if [[ $answer =~ ^[[:space:]]*[nN] ]]; then
    return 1
  fi
  return 0
}

ask_install_path () {
  echo -e "Enter a base ${hl}installtion path${rs}: (default: $default_basepath)"
  echo -e "(A subfolder called \`ygofab\` will be created)"
  read -e basepath
  basepath="${basepath/#\~/$HOME}"
  if [ ! -d "$basepath" ]; then
    basepath="$default_basepath"
  fi
  basepath=$(printf "$basepath" | rev | sed 's|/*||' | rev)
  old_home=$YGOFAB_HOME
  YGOFAB_HOME="$basepath/ygofab"
  echo -e "${bhl}Install path${rs}: $basepath"
  echo -e "${bhl}\$YGOFAB_HOME${rs}: $YGOFAB_HOME"
  echo
  return 0
}

ask_default_configs () {
  echo -e "Enter your default ${hl}YGOPro game directory${rs}:"
  read -e gamedir_path
  gamedir_path="${gamedir_path/#\~/$HOME}"
  gamedir_path=$(printf "$gamedir_path" | rev | sed 's|/*||' | rev)
  printf "Enter an ${hl}identifying name${rs} for your default game directory:"
  echo -e " (default: $default_gamedir_name)"
  read -e gamedir_name
  if [[ ! "$gamedir_name" =~ ^[a-zA-Z][[:alnum:]]*$ ]]; then
    gamedir_name=$default_gamedir_name
  fi
  echo -e "${bhl}Gamedir name${rs}: $gamedir_name"
  echo -e "${bhl}Gamedir path${rs}: $gamedir_path"
  echo
  return 0
}

gen_config () {
  if ! sed "s|\$GAMEDIR_NAME|$gamedir_name|;s|\$GAMEDIR_PATH|$gamedir_path|" \
    $here/config.gen.toml > $YGOFAB_HOME/config.toml; then
    echo -e "${ehl}[ERROR]${rs}: Could not copy files."
    return 1
  fi
  return 0
}

install () {
  echo -e "Installing..."
  # Create ygofab folder if needed
  if [ ! -d $YGOFAB_HOME ]; then
    if ! mkdir $YGOFAB_HOME; then
      echo -e "${ehl}[ERROR]${rs}: Could not create ygofab dir."
      return 1
    fi
  fi
  # Copies all files except config.gen.toml
  local here="${BASH_SOURCE%/*}"
  if ! cp -fR "$here/bin" "$here/res" "$here/scripts" "$here/lib" \
    "$here/LICENSE" "$here/README.md" $YGOFAB_HOME; then
    echo -e "${ehl}[ERROR]${rs}: Could not copy files."
    return 1
  fi
  # Copies or generates config.toml accordingly
  if [ ! -z $gamedir_name ]; then
    gen_config || return 1
  elif [ ! -z $old_home ]; then
    if ! cp -f "$old_home/config.toml" "$YGOFAB_HOME/config.toml"; then
      echo -e "${ehl}[ERROR]${rs}: Could not copy config files."
      return 1
    fi
  fi
  echo -e "${shl}[OK]: ${bhl}YGOFabrica${rs} was successcully installed!"
  printf "\n\nIn order to use the ygofab command, create an envinronment variable "
  printf "called ${hl}\`YGOFAB_HOME\`${rs} with the value ${hl}\`$YGOFAB_HOME\`${rs} "
  echo -e "and add ${hl}\`\$YGOFAB_HOME/bin\`${rs} to your ${hl}\`PATH\`${rs}."
  echo
  return 0
}

# HACK
install || exit 1
exit 0

greet || exit 1
# Is the program installed?
if [ ! -z "$YGOFAB_HOME" ]; then
  echo -e "It seems you already have ${bhl}YGOFabrica${rs} installed."
  echo -e "Do you want to change the ${hl}install path${rs}? (y/N)"
  read change
  # Do you want to change the install path?
  if [[ $change =~ ^[[:space:]]*[yY] ]]; then
    ask_install_path || exit 1
  fi
  echo -e "Do you want to keep your previous ${hl}configurations${rs}? (Y/n)"
  read config
  # Do you want to keep config.toml?
  if [[ $config =~ ^[[:space:]]*[nN] ]]; then
    ask_default_configs || exit 1
  fi
else
  ask_install_path || exit 1
  ask_default_configs || exit 1
fi
install || exit 1
