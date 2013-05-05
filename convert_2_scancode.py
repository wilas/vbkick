#!/usr/bin/env python

# The MIT License
#
# Copyright (c) 2013, Kamil Wilas (wilas.pl)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# Example usage:
# echo 'Hello World!' | python convert_2_scancode.py

# Note:
# When scancode not exist for given char then exception throw

# Helpful links:
# - http://humbledown.org/files/scancodes.l
# - https://github.com/jedi4ever/veewee/blob/master/lib/veewee/provider/core/helper/scancode.rb

import sys
import re

def get_one_char_codes():
    scancodes = {}
    key_map = {'1234567890-=' : 0x02,
        'qwertyuiop[]' : 0x10,
        'asdfghjkl;\'`' : 0x1e,
        '\\zxcvbnm,./' : 0x2b
    }
    for keys, offset in key_map.iteritems():
        idx = 0
        for k in list(keys):
            scancodes[k] = '%02x %02x' % (idx + offset, idx + offset + 0x80)
            idx += 1
    # Shift keys
    key_map =  { '!@#$%^&*()_+' : 0x02,
        'QWERTYUIOP{}' : 0x10,
        'ASDFGHJKL:"~' : 0x1e,
        '|ZXCVBNM<>?' : 0x2b
    }
    for keys, offset in key_map.iteritems():
        idx = 0
        for k in list(keys):
            scancodes[k] = '2a %02x %02x aa' % (idx + offset, idx + offset + 0x80)
            idx += 1
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
        scancodes['<VT%s>' % idx] = '38 %02x b8 %02x' % (idx + 0x3a, idx +0xba)
    return scancodes

if __name__ == "__main__":
    # read from stdin
    input = sys.stdin.readlines()
    # convert input list to string
    input = ''.join(input).rstrip('\n')
    # process <Multiply(what,times)> 
    # example usage: <Multiply(<Wait>,4)> --> <Wait><Wait><Wait><Wait>
    # key thing about multiply_regexpr: match in non-greedy
    multiply_regexpr = '<Multiply\((.+?),[ ]*([\d]+)[ ]*\)>'
    for match in re.finditer(r'%s' % multiply_regexpr, input):
        what = match.group(1)
        times = int(match.group(2))
        # repeating a string given number of times
        replacement = what * times
        # replace Multiply(what,times)> with already created replacement
        input = input.replace(match.group(0), replacement)
    # replace white-spaces with <Spacebar>
    input = input.replace(' ', '<Spacebar>')
    # create list to collect information about input string structure
    keys_array = [-1] * len(input) #-1 mean no key yet assign to cell in array

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

    # process rest codes (single-char)
    scancodes = get_one_char_codes()
    # convert input string to list
    input = list(input)
    # check only not assign yet (with value -1) cells in keys_array
    for index in range(0, len(keys_array)):
        if keys_array[index] == -1:
            keys_array[index] = scancodes[input[index]]

    # remove empty string from keys_array
    keys_array = [x for x in keys_array if x != '']
    # write result to stdout
    print(' '.join(keys_array))

