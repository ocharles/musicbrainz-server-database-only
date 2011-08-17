#!/usr/bin/env perl
use 5.8.8;

use inc::Module::Install;

name 'MusicBrainz-Database';
abstract 'MusicBrainz database server';
author 'MetaBrainz Foundation';
license 'gpl';

# Mandatory modules
requires 'DBD::Pg'            => '2.16';
requires 'DBI'                => '1.609';
requires 'Moose'              => '1.20';
requires 'String::ShellQuote' => '1.03';

author_requires 'Test::NoTabs';
author_requires 'Test::EOL';

install_script glob('script/*.pl');
auto_install;
WriteAll;
