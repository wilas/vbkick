#!/usr/bin/python

# Copyright (c) 2013-2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Example usage:
# echo 'Hello World!' | python convert_2_scancode.py
#
# Note:
# Script work with python 2.6+ and python 3
# When scancode not exist for given char
# then script exit with code 1 and an error is write to stderr.
#
# Helpful links - scancodes:
# - basic: http://humbledown.org/files/scancodes.l (http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html)
# - make and break codes (c+0x80): http://www.win.tue.nl/~aeb/linux/kbd/scancodes-10.html
# - make and break codes table: http://stanislavs.org/helppc/make_codes.html
# - https://github.com/jedi4ever/veewee/blob/master/lib/veewee/provider/core/helper/scancode.rb

from __future__ import absolute_import, division, print_function, unicode_literals

import sys
import re

def _make_scancodes(key_map, str_pattern):
    scancodes = {}
    for keys in key_map:
        offset = key_map[keys]
        for idx, k in enumerate(list(keys)):
            scancodes[k] = str_pattern % (idx + offset, idx + offset + 0x80)
    return scancodes

def get_one_char_codes():
    key_map = {'1234567890-=' : 0x02,
        'qwertyuiop[]' : 0x10,
        'asdfghjkl;\'`' : 0x1e,
        '\\zxcvbnm,./' : 0x2b
    }
    scancodes = _make_scancodes(key_map, '%02x %02x')
    # Shift keys
    key_map =  { '!@#$%^&*()_+' : 0x02,
        'QWERTYUIOP{}' : 0x10,
        'ASDFGHJKL:"~' : 0x1e,
        '|ZXCVBNM<>?' : 0x2b
    }
    scancodes.update(_make_scancodes(key_map, '2a %02x %02x aa'))
    return scancodes

def get_multi_char_codes():
    scancodes = {}
    scancodes['<Enter>'] = '1c 9c'
    scancodes['<Backspace>'] = '0e 8e'
    scancodes['<Spacebar>'] = '39 b9'
    scancodes['<Return>'] = '1c 9c'
    scancodes['<Esc>'] = '01 81'
    scancodes['<Tab>'] = '0f 8f'
    scancodes['<KillX>'] = '1d 38 0e b8'
    scancodes['<Wait>'] = 'wait'
    scancodes['<Up>'] = '48 c8'
    scancodes['<Down>'] = '50 d0'
    scancodes['<PageUp>'] = '49 c9'
    scancodes['<PageDown>'] = '51 d1'
    scancodes['<End>'] = '4f cf'
    scancodes['<Insert>'] = '52 d2'
    scancodes['<Delete>'] = '53 d3'
    scancodes['<Left>'] = '4b cb'
    scancodes['<Right>'] = '4d cd'
    scancodes['<Home>'] = '47 c7'
    # F1..F10
    for idx in range(1,10):
        scancodes['<F%s>' % idx] = '%02x' % (idx + 0x3a)
    # VT1..VT12 (Switch to Virtual Terminal)
    for idx in range(1,12):
        # LeftAlt + RightCtrl + F1-12
        scancodes['<VT%s>' % idx] = '38 e0 1d %02x b8 e0 9d %02x' % (idx + 0x3a, idx +0xba)
    return scancodes

def process_multiply(input):
    # process <Multiply(what,times)>
    # example usage: <Multiply(<Wait>,4)> --> <Wait><Wait><Wait><Wait>
    # key thing about multiply_regexpr: match is non-greedy
    multiply_regexpr = '<Multiply\((.+?),[ ]*([\d]+)[ ]*\)>'
    for match in re.finditer(r'%s' % multiply_regexpr, input):
        what = match.group(1)
        times = int(match.group(2))
        # repeating a string given number of times
        replacement = what * times
        # replace Multiply(what,times)> with already created replacement
        input = input.replace(match.group(0), replacement)
    return input

def translate_chars(input):
    # create list to collect information about input string structure
    # -1 mean no key yet assign to cell in array
    keys_array = [-1] * len(input)

    # proces multi-char codes/marks (special)
    spc_scancodes = get_multi_char_codes()
    for spc in spc_scancodes:
        # find all spc code in input string and mark correspondence cells in keys_array
        for match in re.finditer(spc, input):
            s = match.start()
            e = match.end()
            # mark start pos given match as scancode in keys_array
            keys_array[s] = spc_scancodes[spc]
            # mark rest pos given match as empty string in keys_array
            for i in range(s+1, e):
                keys_array[i] = ''

    # process single-char codes
    scancodes = get_one_char_codes()
    # convert input string to list
    input = list(input)
    # check only not assign yet (with value equal -1) cells in keys_array
    for index, _ in enumerate(keys_array):
        if keys_array[index] != -1:
            continue
        try:
            keys_array[index] = scancodes[input[index]]
        except KeyError:
            sys.stderr.write('Error: Unknown symbol found - %s\n' % repr(input[index]))
            sys.exit(1)

    # remove empty string from keys_array
    keys_array = [x for x in keys_array if x != '']
    return keys_array


if __name__ == "__main__":
    # read from stdin
    input = sys.stdin.readlines()
    # convert input list to string
    input = ''.join(input).rstrip('\n')
    # process multiply
    input = process_multiply(input)
    # replace white-spaces with <Spacebar>
    input = input.replace(' ', '<Spacebar>')
    # process keys
    keys_array = translate_chars(input)
    # write result to stdout
    print(' '.join(keys_array))

