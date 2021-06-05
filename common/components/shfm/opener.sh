#!/bin/sh -e
#
# open file in application based on mime-type

mime_type=$(file -bi "$1")

case $mime_type in
    audio/*)
       mpv --no-video "$1"
    ;;

    video/*)
        run_gpu mpv "$1"
    ;;

    image/*)
        feh "$1"
    ;;

    text/html*)
        firefox "$1"
    ;;

    application/pdf*)
        zathura "$1"
    ;;

    text/*)
        "${EDITOR}" "$1"
    ;;

    *)
        printf 'unknown mime-type %s\n' "$mime_type"
    ;;
esac
