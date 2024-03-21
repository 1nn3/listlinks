#!/usr/bin/env perl

use v5.36;

use strict;
use warnings;

use Data::Dumper;
use Selenium::Chrome;

my $driver = Selenium::Chrome->new(
    'extra_capabilities' => {
        'goog:chromeOptions' => {
            'args' => [
                'disable-gpu',
                'headless',
                #'window-size=1260,960', # sollte frei wählbar sein
            ],
        }
    }
);

$driver->get("https://www.example.net");

print Dumper ( $driver->get_title() );

END {
    $driver->shutdown_binary();
}

