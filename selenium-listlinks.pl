#!/usr/bin/env perl

# pragmas
use diagnostics;
use locale;
use strict;
use utf8;
use warnings;

# core modules
use Data::Dumper;
use Getopt::Long;
use URI;

# CPAN modules
#use Selenium::Firefox;
#use Selenium::Firefox::Profile;
use Selenium::Chrome;
use Selenium::Remote::Driver;
use Selenium::Remote::WebElement;

binmode( STDIN,  ":encoding(UTF-8)" );
binmode( STDOUT, ":encoding(UTF-8)" );
binmode( STDERR, ":encoding(UTF-8)" );

our $VERSION = "1";

our $frame_recursion_max_depth = 10;
our $stay                      = 0;
our $timeout                   = 10;
our $uri                       = undef;
GetOptions(
    "frame-recursion-max-depth=i" => \$frame_recursion_max_depth,
    "stay=i"                      => \$stay,
    "timeout=i"                   => \$timeout,
    "uri=s"                       => \$uri,
) || die("Error in command-line-arguments: $!");
$uri //= $ARGV[0];

#my $profile = Selenium::Firefox::Profile->new();
#my $driver  = Selenium::Firefox->new(
#    firefox_profile => $profile,
#    startup_timeout => $timeout,
#);
my $driver = Selenium::Chrome->new();

#$driver->debug_on;
#$driver->set_timeout( 'script',    $timeout * 1000 ); # milliseconds
#$driver->set_timeout( 'implicit',  $timeout * 1000 ); # milliseconds
#$driver->set_timeout( 'page load', $timeout * 1000 ); # milliseconds

sub list_links {
    for ( $driver->find_elements("//a") ) {
        my $href = $_->get_attribute("href") || "";
        $href = URI->new($href)->abs( URI->new($uri) )->as_string || $href;
        my $text = $_->get_text || "";
        $text =~ s/\s+/ /g;
        print "$href\t$text\n";
    }
}

sub get_frames {
    my (@parrents) = @_;
    my @elements   = $driver->find_elements("//iframe");
    my @frames     = ();
    #for ( my $i = 0 ; $i < scalar(@elements) ; $i++ ) {
    #    push( @frames, [ @parrents, $i ] );    # frame position
    #}
    for (@elements) {
        push( @frames, [ @parrents, $_ ] );    # frame element
    }
    return @frames;
}

sub walk_through_frames {
    my (@frames) = @_;
    for (@frames) {

        #printf STDERR "I: Switching to frame: %s\n", join( ".", @{$_} );

        if ( scalar( @{$_} ) > $frame_recursion_max_depth ) {
            warn "W: frame_recursion_max_depth reached!";
            next;
        }

        $driver->switch_to_frame(undef);    # main frame
        for ( @{$_} ) {
            $driver->switch_to_frame($_);
        }

        list_links;
        walk_through_frames( get_frames( @{$_} ) );    # subframes
    }
}

eval {
    $driver->get($uri);
    sleep($stay);
    list_links;
    walk_through_frames( get_frames( () ) );
};
$@ && die "E: $uri: $@";

END {
    $driver->shutdown_binary;
}

