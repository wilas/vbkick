#!/usr/bin/perl

#
# Copyright (c) 2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Example usage:
# echo 'Hello World!' | perl vbtyper.pl
#
# Helpful links - scancodes:
# - basic: http://humbledown.org/files/scancodes.l
# - basic: http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
# - make and break codes (c+0x80): http://www.win.tue.nl/~aeb/linux/kbd/scancodes-10.html
# - make and break codes table: http://stanislavs.org/helppc/make_codes.html
#
use warnings;
use strict;
use Data::Dumper;

my $DEBUG=0;

sub _make_scancodes {
    my ($key_map, $str_pattern) = @_;
    my %scancodes = ();
    for my $key ( keys %$key_map ) {
        my $offset = $key_map->{$key};
        for (my $idx = 0; $idx < length($key); $idx++) {
            my $char=substr($key, $idx, 1);
            $scancodes{$char} = sprintf($str_pattern,
                $idx + $offset, $idx + $offset + 0x80);
        }
    }
    return \%scancodes;
}

sub get_one_char_codes {
    my %key_map = (
        '1234567890-='  => 0x02,
        'qwertyuiop[]'  => 0x10,
        'asdfghjkl;\'`' => 0x1e,
        '\\zxcvbnm,./'  => 0x2b
    );
    my $scancodes = _make_scancodes(\%key_map, '%02x %02x');
    # Shift keys
    %key_map =  (
        '!@#$%^&*()_+'  => 0x02,
        'QWERTYUIOP{}'  => 0x10,
        'ASDFGHJKL:"~'  => 0x1e,
        '|ZXCVBNM<>?'   => 0x2b
    );
    my $shift_scancodes = _make_scancodes(\%key_map, '2a %02x %02x aa');
    @{$scancodes}{keys %$shift_scancodes} = values %$shift_scancodes;
    return $scancodes;
}

sub get_multi_char_codes {
    my %scancodes = (
        '<Enter>'       => '1c 9c',
        '<Backspace>'   => '0e 8e',
        '<Spacebar>'    => '39 b9',
        '<Return>'      => '1c 9c',
        '<Esc>'         => '01 81',
        '<Tab>'         => '0f 8f',
        '<KillX>'       => '1d 38 0e b8',
        '<Wait>'        => 'wait',
        '<Up>'          => '48 c8',
        '<Down>'        => '50 d0',
        '<PageUp>'      => '49 c9',
        '<PageDown>'    => '51 d1',
        '<End>'         => '4f cf',
        '<Insert>'      => '52 d2',
        '<Delete>'      => '53 d3',
        '<Left>'        => '4b cb',
        '<Right>'       => '4d cd',
        '<Home>'        => '47 c7',
        '<Lt>'          => '2a 33 b3 aa', #to type '<' - e.g. <Enter> literally
        '<Gt>'          => '2a 34 b4 aa', #to type '>' - e.g. <<Wait*5>*2> literally
    );
    # F1..F10
    for (my $idx = 1; $idx <= 10; $idx++) {
        $scancodes{sprintf("<F$idx>")} = sprintf('%02x', $idx + 0x3a);
    }
    # VT1..VT12 (Switch to Virtual Terminal)
    for (my $idx = 1; $idx <= 12; $idx++) {
        # LeftAlt + RightCtrl + F1-12
        $scancodes{sprintf("<VT$idx>")} = sprintf('38 e0 1d %02x b8 e0 9d %02x',
            $idx + 0x3a, $idx + 0xba);
    }
    return \%scancodes;
}

# this method is deprecated and will be remove in v0.9
sub process_multiply_old {
    my ($input) = @_;
    # process <Multiply(what,times)>
    # example usage: <Multiply(<Wait>,4)> --> <Wait><Wait><Wait><Wait>
    # key thing about multiply_regexpr: match is non-greedy
    my $multiply_regexpr = '<Multiply\((.+?),[ ]*([\d]+)[ ]*\)>';
    # repeating a string 'what' given number of 'times'
    # 'e' makes the difference; it evaluates the substitution part as Perl code
    # $1 is what
    # $2 is times
    # replacement = what x times
    $input =~ s/$multiply_regexpr/$1x$2/eg;
    return $input;
}

sub process_multiply {
    my ($input) = @_;
    # process <what*times>
    # example usage: <<Wait>*4> --> <Wait><Wait><Wait><Wait>
    # key thing about multiply_regexpr: match is non-greedy
    my $multiply_regexpr = '<(.+?)\*([\d]+)>';
    # repeating a string 'what' given number of 'times'
    # 'e' makes the difference; it evaluates the substitution part as Perl code
    # $1 is what
    # $2 is times
    # replacement = what x times
    $input =~ s/$multiply_regexpr/$1x$2/eg;
    return $input;
}

sub translate_chars {
    my ($input) = @_;
    # create list to collect information about input string structure
    # -1 mean no key yet assign to cell in array
    my @keys_array = (-1) x length($input);

    # proces multi-char codes/marks (special)
    # find all special codes in input string
    # and mark correspondence cells in keys_array
    my $multi_char_regexpr = '(<[^<> ]+>)';
    my $spc_scancodes = get_multi_char_codes();
    while ( $input =~ /$multi_char_regexpr/g) {
        if ( not defined $spc_scancodes->{$1} ) {
            next;
        }
        my $s = pos($input)-length($1);
        my $e = pos($input);
        if ($DEBUG) {
            print "[SPC] $1, $s-$e\n";
        }
        $keys_array[$s] = $spc_scancodes->{$1};
        for (my $i = $s+1; $i < $e; $i++) {
            $keys_array[$i]='';
        }
    }

    # process single-char codes
    my $scancodes = get_one_char_codes();
    my @input_array = split //, $input;
    for my $index (0 .. $#keys_array) {
        #process only not assign yet (with value equal -1) cells in keys_array
        if ($keys_array[$index] ne -1){
            next;
        }
        my $char = $input_array[$index];
        if ( not defined $scancodes->{$char} ){
            die("Error: Unknown symbol found - '$char' -");
        }
        $keys_array[$index] = $scancodes->{$char};
    }
    if ($DEBUG) {
        print Dumper(@keys_array);
    }

    # remove empty string from keys_array and return a new array
    return grep { defined() and length() } @keys_array;
}

sub preformat_input {
    my ($input) = @_;
    # remove trailing new line - useful when string is send using echo
    $input =~ s/\n$//;
    # process multiply before translation starts
    $input = process_multiply_old( $input );
    $input = process_multiply( $input );
    # replace spaces with <Spacebar>
    $input =~ s/ /<Spacebar>/g;
    # replace middle new lines with <Enter>
    $input =~ s/\n/<Enter>/g;
    # replace tabs with <Tab>
    $input =~ s/\t/<Tab>/g;
    return $input;
}

sub get_vbox_manage_bin {
    my $VBoxManage=$ENV{'VBOX_MANAGE_PATH'};
    if (not $VBoxManage){
        $VBoxManage = "VBoxManage";
    }
    return $VBoxManage;
}

sub main {
    my @argv = @_;

    # parse args
    my $num_args = $#argv + 1;
    my $vm = undef;
    if ($num_args eq 1) {
        $vm = $argv[0];
    }

    # reads input string from STDIN
    my $input = do { local $/; <STDIN> };

    $input = preformat_input($input);
    # process keys
    my @keys_array = translate_chars( $input );
    if (not $vm){
        # write result to stdout
        print join(" ",@keys_array), "\n";
    }
    else{
        # types keys directy to the VM
        my $VBoxManage = get_vbox_manage_bin();
        foreach my $key_code (@keys_array) {
            if ($key_code eq "wait"){
                sleep(1);
                next;
            }
            # $key_code containg press and release hexes
            # split is needed to type it as a separate hexes not as a string
            my $status = system("$VBoxManage", "controlvm", "$vm",
                "keyboardputscancode", split(/ /, $key_code));
            if ($status ne 0){
                print STDERR "[ERROR] Couldn't type '$key_code'",
                    "to the '$vm'.\n";
                exit(1);
            }
            # add small delay between keys
            sleep(0.02);
        }
    }
}

main( @ARGV );

# vim modeline
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
