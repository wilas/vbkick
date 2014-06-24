#!/usr/bin/perl

#
# Copyright (c) 2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Simple web server in Perl for the needs of vbkick.
# Serves out files and directories, echos form data.
# Only the Perl Standard Library are used - no lib dependencies.
#
# Useful - http protocol spec: http://www.w3.org/Protocols/rfc2616/rfc2616.html
#

use warnings;
use strict;
use Socket;
use IO::Socket;
use Data::Dumper;

my $DEBUG=0;
my $server_version = "vbhttp/0.8";
my $sys_version = "perl/$]";

my @mon = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @day = qw( Sun Mon Tue Wed Thu Fri Sat );

my %html_responses = (
    # codes: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.1
    200 => "OK",
    301 => "Moved Permanently",
    400 => "Bad Request",
    403 => "Forbidden",
    404 => "Not Found",
);
my %html_url_encode = (
    # only a few useful, more: http://www.w3schools.com/tags/ref_urlencode.asp
    ' ' => "%20",
    '!' => "%21",
    '"' => "%22",
    '#' => "%23",
    '$' => "%24",
    '%' => "%25",
    '&' => "%26",
    "'" => "%27",
    '/' => "%2F",
    '?' => "%3F",
    '\\' => "%5C",
);

sub send_status_code {
    my ($conn, $code, $url) = @_;
    my $content = "<html><body>$code $html_responses{$code}</body></html>";
    my $header = make_header($code, "text/html", length($content), $url);
    if ($DEBUG) {
        print "[RESP_HEADER]: $header\n";
    }
    print $conn "$header$content";
}

sub make_header {
    my ($code, $content_type, $content_length, $url) = @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime;
    my $datestring = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT",
        $day[$wday], $mday, $mon[$mon], $year+1900, $hour, $min, $sec);
    # The Status-Line and headers must all end with <CR><LF>
    my $header = join("",
        "HTTP/1.1 $code $html_responses{$code}", Socket::CRLF,
        "Content-type: $content_type; charset=UTF-8", Socket::CRLF,
        "Content-Length: $content_length", Socket::CRLF,
        "Date: $datestring", Socket::CRLF,
        "Server: $server_version $sys_version", Socket::CRLF
        );
    if (defined $url){
        $header = join("", $header, "Location: $url", Socket::CRLF);
    }
    $header = join("", $header, Socket::CRLF);
    return $header;
}

sub list_directory {
    my ($conn, $dirname) = @_;
    my $response_code = 500;
    if (opendir(DIR, $dirname)){
        my $content = join("",
            "<html>\n<title>Directory listing for $dirname</title>\n",
            "<body>\n<h2>Directory listing for $dirname</h2>\n",
            "<hr>\n<ul>\n");
        while (my $file = readdir(DIR)) {
            # Ignore files beginning with a period
            next if ($file =~ m/^\./);
            # Create links for directories and files
            # Add trailing "/" for directories - needed for relative URLs
            if (-f "$dirname/$file"){
                $content = join("", $content,
                    qq{<li><a href="$file">$file</a>\n});
            }
            elsif (-d "$dirname/$file"){
                $content = join("", $content,
                    qq{<li><a href="$file/">$file</a>\n});
            }
        }
        $content = join("", $content, "</ul>\n<hr>\n</body>\n</html>\n");
        my $header = make_header(200, "text/html", length($content));
        print $conn "$header$content";
        $response_code = 200;
    }
    else {
        send_status_code( $conn, 403 );
        $response_code = 403;
    }
    closedir(DIR);
    return $response_code;
}

sub cat_file {
    my ($conn, $filename) = @_;
    my $response_code = 500;
    if (open(FILE, "<$filename")) {
        my $filesize = -s "$filename";
        my $header = make_header(200, "text/plain", $filesize);
        print $conn "$header";
        my $buffer; # useful for binary data
        while (read(FILE, $buffer, 4096)) {
            print $conn $buffer;
        }
        $response_code = 200;
    }
    else {
        send_status_code( $conn, 403 );
        $response_code = 403;
    }
    close(FILE);
    return $response_code;
}

sub get_request {
    my ($conn) = @_;

    # Default request values
    my %request = ();
    $request{METHOD} = "ERROR";
    $request{URL} = "";
    $request{HTTP_VERSION} = "HTTP/0.0";

    # Read and parse HTTP request
    # The request line and headers must all end with <CR><LF>
    # Set "end of line" special variable to common socket "newline" constant
    # CRLF = \015\012
    local $/ = Socket::CRLF;
    while (my $message = <$conn>) {
        chomp $message;
        if ($DEBUG) {
            print "Message: [$message]\n";
        }
        # Checks request type - if "GET" then collect all needed informations
        # GET /example/subpage HTTP/1.1
        if ($message =~ /\s*GET\s*([^\s]+)\s*HTTP\/(\d.\d)/) {
            $request{METHOD} = "GET";
            $request{URL} = $1;
            $request{HTTP_VERSION} = "HTTP/$2";
        } # Parse HTTP header fields
        elsif ($message =~ /:/) {
            my ($field_name, $field_val) = split /:/, $message, 2;
            # trim leading and trailing white spaces from the fields name and value
            $field_name =~ s/^\s+|\s+$//g;
            $field_val =~ s/^\s+|\s+$//g;
            $request{$field_name} = $field_val;
        } # Full message was read - ends loop
        elsif ($message =~ /^$/) {
            last;
        }
    }
    # return reference to request
    return \%request;
}

sub translate_path {
    my ($path) = @_;
    # Decode url
    keys %html_url_encode; # reset the internal iterator
    while ( my ($file_code, $url_code) = each(%html_url_encode) ){
        $path =~ s/$url_code/$file_code/g;
    }
    return $path;
}

sub log_request {
    my ($request, $response_code) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    my $datestring = sprintf("%02d/%s/%04d %02d:%02d:%02d",
        $mday, $mon[$mon], $year+1900, $hour, $min, $sec);
    print join(" ", "[$datestring]",
        qq{- "$request->{METHOD} $request->{URL} $request->{HTTP_VERSION}"},
        "$response_code -\n");
}

sub handle_connection {
    my ($conn) = @_;

    my $document_root = ".";
    my $request = get_request( $conn );
    if ($DEBUG) {
        print Dumper($request);
    }

    # Only "GET" request are supported
    if ($request->{"METHOD"} ne "GET"){
        send_status_code( $conn, 400 );
        log_request($request, 400);
        return;
    }

    my $response_code = 500;
    # Remember: $request->{URL} contain leading "/"
    my $localfile = translate_path( "$document_root$request->{URL}" );
    if (-f $localfile) {
        $response_code = cat_file($conn, $localfile);
    }
    elsif (-d $localfile) {
        # if directory dosen't contain a trailing "/" then redirect with 301
        if ($localfile !~ /\/$/){
            # remove leading dot from the redirect url
            $localfile =~ s/^\.//g;
            send_status_code($conn, 301, "$localfile/");
            $response_code = 301;
        }
        else{
            $response_code = list_directory($conn, $localfile);
        }
    }
    else{
        # file not found
        send_status_code($conn, 404 );
        $response_code = 404;
    }
    log_request($request, $response_code);
}

sub main {
    # Parse args
    my $port = shift;
    defined($port) or die "Usage: vbhttp PORT\n";
    # Setup and create socket
    my $sock = new IO::Socket::INET(Proto     => 'tcp',
                                    LocalAddr => '127.0.0.1',
                                    LocalPort => $port,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1);
    $sock or die "Unable to create server socket: $!";
    print "Serving HTTP on 127.0.0.1 port $port ...\n";
    # Await requests and handle them as they arrive
    while (my $connection = $sock->accept()) {
        # flush so output gets there right away
        $connection->autoflush(1);
        handle_connection( $connection );
        close $connection;
    }
}

main( @ARGV );

# vim modeline
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
