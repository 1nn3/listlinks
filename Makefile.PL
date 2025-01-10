use strict;
use utf8;
use warnings;

use ExtUtils::MakeMaker;
use File::ShareDir::Install;
use File::Spec;

my $pm  = File::Spec->catfile( 'lib', 'App', 'SeleniumScripts.pm' );
my $pod = File::Spec->catfile( 'pod', 'listlinks.pod' );

install_share dist => 'dist';

WriteMakefile(
    NAME          => 'App-SeleniumScripts',
    VERSION_FROM  => $pm,
    AUTHOR        => q{user <user@host>},
    ABSTRACT_FROM => $pod,

    #NO_MYMETA => 1,
    MAN1PODS => {
        'pod/clicklinks.pod'     => '$(INST_MAN1DIR)/clicklinks.1p',
        'pod/listlinks.pod'      => '$(INST_MAN1DIR)/listlinks.1p',
        'pod/selenium-xpath.pod' => '$(INST_MAN1DIR)/selenium-xpath.1p',
    },
    MAN3PODS => {},
    EXE_FILES => [ 'bin/clicklinks', 'bin/listlinks', 'bin/selenium-xpath', ],
    PREREQ_PM => {
        'Config::Tiny'             => undef,
        'Data::Dumper'             => undef,
        'Env'                      => undef,
        'Fcntl'                    => undef,
        'File::HomeDir'            => undef,
        'File::ShareDir'           => undef,
        'File::Spec'               => undef,
        'Getopt::Long'             => undef,
        'List::Util'               => undef,
        'Net::Netrc'               => undef,
        'Selenium::Remote::Driver' => undef,
        'Storable'                 => undef,
        'URI'                      => undef,
    },
);

package MY;
use File::ShareDir::Install qw(postamble);

