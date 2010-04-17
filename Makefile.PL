use inc::Module::Install;

name     'HTTP-Easy';
all_from 'lib/HTTP/Easy.pm';
author   q{Mons Anderson <mons@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

