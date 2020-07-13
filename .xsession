#!/bin/sh

#
# ~/.xsession
#
# Executed by xdm/gdm/kdm at login
#

# start some nice programs

export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

## X設定
xset b off
setxkbmap -model jp106 -layout jp -option "ctrl:swapcaps"
xmodmap -e "add mod4 = Muhenkan"
xmodmap -e "add mod5 = Henkan"


## アプリケーション
#pulseaudio -D
fcitx -r -d
conky -d
nitrogen --restore
xscreensaver -no-splash &
xcompmgr &
cbatticon &

## ウィンドウマネージャ
exec awesome
