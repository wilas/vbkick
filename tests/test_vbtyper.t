#!/usr/bin/perl

use strict;
use warnings;

use Test::More "no_plan";

BEGIN { use_ok( 'vbtyper', qw(process_multiply translate_chars) ); }


note('Testing "process_multiply" subroutine');
my $expected = 'aaaa';
my $got = process_multiply('<aa*2>');
is ($got, $expected, 'basic test for multiply');

$expected = 'aaa';
$got = process_multiply('<aa*2>');
isnt ($got, $expected, 'negative test for multiply');

$expected = '<Wait><Wait>*2>';
$got = process_multiply('<<Wait>*2>*2>');
is ($got, $expected, 'advance test1 for multiply');

$expected = '<<Wait><<Wait>*2>';
$got = process_multiply('<<<Wait>*2>*2>');
is ($got, $expected, 'advance test2 for multiply');


note('Testing "translate_chars" subroutine');
my @expected = ('1e 9e', '1e 9e');
my @got = translate_chars('aa');
is_deeply(\@got, \@expected , 'basic test for translate chars');

@expected = ('2a 1e 9e aa', '2a 1e 9e aa');
@got = translate_chars('AA');
is_deeply(\@got, \@expected , 'basic test with Shift for translate chars');

@expected = ('1e 9e', 'wait');
@got = translate_chars('a<Wait>');
is_deeply(\@got, \@expected , 'basic test with <Wait> for translate chars');

@expected = ('0f 8f', '1c 9c');
@got = translate_chars('<Tab><Enter>');
is_deeply(\@got, \@expected , 'basic test with special keys for translate chars');

# vim modeline
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
