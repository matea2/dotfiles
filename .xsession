#!/bin/sh

#
# ~/.xsession
#
# Executed by xdm/gdm/kdm at login
#

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

# merge in defaults and keymaps

if [ -f $userresources ]; then
	xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
	xmodmap $usermodmap
fi

# start some nice programs

export PATH="$PATH:$HOME/bin"
export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

## X設定
xset b off
xsetroot -cursor_name Adwaita
setxkbmap -model jp106 -layout jp -option "ctrl:swapcaps"
xmodmap -e "keysym Muhenkan = Super_L"
xmodmap -e "keysym Henkan = Super_L"

xinput --set-prop "AlpsPS/2 ALPS GlidePoint" "Synaptics Tap Action" 0, 0, 0, 0, 0, 0, 0
xinput --set-prop "AlpsPS/2 ALPS GlidePoint" "Synaptics Edge Scrolling" 1, 1, 0
#xinput --set-prop "SynPS/2 Synaptics TouchPad" "Device Enabled" 0

## アプリケーション
pulseaudio -D
fcitx -r -d
urxvtd -q -o -f
conky -d
#nitrogen --restore
ls -d ~/.config/feh/background/* | shuf -n 1 | feh --bg-max --filelist -
xscreensaver -no-splash &
xcompmgr &

## ウィンドウマネージャ
exec awesome
