# DarkQuark

## Palette

background:             #000000
lighter_background:     #151510

foreground:             #d2cad3
lighter_foreground:     #f8f0f8

black:                  #08040b
dark_gray:              #554d5b

red:                    #a52e4d
light_red:              #fa83a2

green:                  #228039
light_green:            #44a29f

yellow:                 #996f06
light_yellow:           #ddc47d

blue:                   #006fc1
light_blue:             #6691d2

purple:                 #aa3c9f
light_purple:           #c29dd5

cyan:                   #33b3f4
light_cyan:             #88c4f4

gray:                   #bbb3c1
white:                  #f8f0f8

## Helper Scripts

```py
def tint(color):
    return hex((color + 0x08040b) - 0x080808)

def redshift(color):
    return hex((color + 0x130606) - 0x0d0d0d)
```
