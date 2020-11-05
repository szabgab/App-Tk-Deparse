use strict;
use warnings;
use Test::More;

use App::Tk::Deparse;

if (not $ENV{TRAVIS} and not $ENV{GITHUB_ACTIONS}) {
    App::Tk::Deparse->new;
}

pass;


done_testing();
