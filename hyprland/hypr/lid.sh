#! /usr/bin/env zsh


if [[ "$(hyprctl monitors)" =~ "eDP-1" ]]; then
	echo $1
  if [[ $1 == "open" ]]; then
    echo "HEY MAN FUCK YOU OPEN"
    hyprctl keyword monitor "eDP-1,preferred,auto,auto"
  else
    echo "HEY MAN FUCK YOU CLOSE"
    hyprctl keyword monitor "eDP-1,disable"
  fi
fi
