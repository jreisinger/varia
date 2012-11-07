use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Animal',
    license             => 'perl',
    dist_author         => q{Foo Bar <foo@bar.org>},
    dist_version_from   => 'lib/Animal.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Animal-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
