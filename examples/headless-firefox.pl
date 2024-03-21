#!/usr/bin/env perl

use v5.36;

use strict;
use warnings;

use Data::Dumper;
use Selenium::Firefox;

my $driver = Selenium::Firefox->new(
    'extra_capabilities' => {
        'moz:firefoxOptions' => {
            'args' => ["--headless"],
        },
    },
);

$driver->get("https://www.example.net");

print Dumper ( $driver->get_title() );

END {
    $driver->shutdown_binary();
}

