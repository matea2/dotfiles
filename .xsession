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
setxkbmap -model jp106 -layout jp -option "ctrl:swapcaps"
xmodmap -e "add mod4 = Muhenkan"
xmodmap -e "add mod5 = Henkan"

#xinput --set-prop "AlpsPS/2 ALPS GlidePoint" "Synaptics Tap Action" 0, 0, 0, 0, 0, 0, 0
#xinput --set-prop "AlpsPS/2 ALPS GlidePoint" "Synaptics Edge Scrolling" 1, 1, 0
#xinput --set-prop "SynPS/2 Synaptics TouchPad" "Device Enabled" 0

## アプリケーション
#pulseaudio -D
fcitx -r -d
urxvtd -q -o -f
conky -d
nitrogen --restore
xscreensaver -no-splash &
xcompmgr &
cbatticon &

## ウィンドウマネージャ
exec awesome
