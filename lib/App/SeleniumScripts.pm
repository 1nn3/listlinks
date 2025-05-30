use v5.36;

use locale;
use strict;
use utf8;
use warnings;

use Config::Tiny;
use File::HomeDir;
use File::ShareDir;
use File::Spec;
use Getopt::Long;
use Selenium::Firefox;
use Selenium::Firefox::Profile;
use Selenium::Remote::Driver;
use Selenium::Remote::WebElement;
use Selenium::Waiter;
use Storable;
use URI;

binmode( STDIN,  ":encoding(UTF-8)" );
binmode( STDOUT, ":encoding(UTF-8)" );
binmode( STDERR, ":encoding(UTF-8)" );

package App::SeleniumScripts {

    our $VERSION = "1.00";
    our $NAME    = "App-SeleniumScripts";

    # ~/.config/Perl
    our $CONFIG_DIR = File::HomeDir->my_dist_config( $NAME, { create => 1 } );

    # ~/.local/share/Perl
    our $DIST_DIR = File::HomeDir->my_dist_data( $NAME, { create => 1 } );

    # File::ShareDir::dist_dir works only if directory is installed
    # /usr/share/perl
    our $DISTDIR = eval { return File::ShareDir::dist_dir($NAME); };

    our @dirs = ( $CONFIG_DIR, $DIST_DIR, $DISTDIR );

    our $COOKIES_DIR = File::Spec->catdir( $CONFIG_DIR, "cookies" );

    our $CONFIG_FILE = File::Spec->catdir( $CONFIG_DIR, "config.ini" );
# Use Config::Tiny instead of Config::Any; because its available in the most distributions
    our $config      = Config::Tiny->new();
# Config::Tiny->read returns the object on success, or undef on error
    $config = Config::Tiny->read($CONFIG_FILE)
	or warn $Config::Tiny::errstr;

    #
    # Cookies öffnen
    #

    sub load_cookies {
        my ( $driver, $rel_cookies_file ) = @_;
        my $path = File::Spec->catdir( $App::SeleniumScripts::COOKIES_DIR,
            $rel_cookies_file );

        warn "Loading cookie $path";

        my $cookies = ( -r $path ) ? Storable::retrieve($path) : [];
        for ( @{$cookies} ) {

            $_->{secure}   = 0;    # overwrite
            $_->{httponly} = 0;    # overwrite

            $driver->add_cookie(
                $_->{name},   $_->{value},  $_->{path},
                $_->{domain}, $_->{secure}, $_->{httponly}
            );
        }
    }

    #
    # Cookies speichern
    #

    sub save_cookies {
        my ( $driver, $rel_cookies_file ) = @_;
        my $path = File::Spec->catdir( $App::SeleniumScripts::COOKIES_DIR,
            $rel_cookies_file );

        warn "Saving cookie $path";

        mkdir $App::SeleniumScripts::COOKIES_DIR
            || die "${App::SeleniumScripts::COOKIES_DIR}: $!";
        Storable::store( $driver->get_all_cookies, $path );
    }

    sub close_popup_windows {
        my ($driver) = @_;
        my $handles = $driver->get_window_handles();
        for ( my $i = 1; $i < scalar(@$handles); $i++ ) {
            $driver->switch_to_window( $handles->[$i] );
            $driver->close();
        }
        $driver->switch_to_window( $handles->[0] );
    }

    #
    # Wait For Page To Load
    #
    # my $driver = Selenium::Remote::Driver->new;
    # $driver->get('https://www.example.net');
    # wait_for_page_to_load($driver);
    #

    sub wait_for_page_to_load {
        my ( $driver, $params ) = @_;
        $params->{timeout} //= 10;

        # javascript to wail for page to load

        return Selenium::Waiter::wait_until {
            $driver->execute_script( '
return document.readyState;
' ) eq 'complete'
        }, timeout => $params->{timeout};
    }

    sub scroll_page_down {
        my ( $driver, $params ) = @_;
        $params->{timeout} //= 10;

        # javascript to scroll page down

        return Selenium::Waiter::wait_until {
            $driver->execute_script( '
function getRandomInt(max) {
    // returns a random integer from 0 to value of max
    return Math.floor(Math.random() * (max + 1));
}

window.scrollBy(0, getRandomInt( document.body.scrollHeight ));
' )
        }, timeout => $params->{timeout};
    }

    1;
}

