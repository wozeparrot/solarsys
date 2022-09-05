def tint(color):
    return (color + 0x08040B) - 0x080808


def redshift(color):
    return (color + 0x130606) - 0x0D0D0D


def rev_tint(color):
    return (color + 0x080808) - 0x08040B


def rev_redshift(color):
    return (color + 0x0D0D0D) - 0x130606


def lighten(color):
    return color + 0x131212


def darken(color):
    return color - 0x131212


c = int(input(": "), 16)

while True:
    o = input("> ")
    if o == "rr":
        c = rev_redshift(c)
        print(hex(c))
    elif o == "rt":
        c = rev_tint(c)
        print(hex(c))
    elif o == "r":
        c = redshift(c)
        print(hex(c))
    elif o == "t":
        c = tint(c)
        print(hex(c))
    elif o == "l":
        c = lighten(c)
        print(hex(c))
    elif o == "d":
        c = darken(c)
        print(hex(c))
