use 5.008008;
use ExtUtils::MakeMaker;

$ENV{AUTHOR} and require CPAN::Meta;

WriteMakefile(
	NAME               => 'HTTP::Easy',
	VERSION_FROM       => 'lib/HTTP/Easy.pm', # finds $VERSION
	ABSTRACT_FROM      => 'lib/HTTP/Easy.pm', # retrieve abstract from module
	CONFIGURE_REQUIRES => {
		"ExtUtils::MakeMaker" => 0,
	},
	BUILD_REQUIRES     => {
		'lib::abs'            => 0,
		'URI'                 => 0,
		'Test::More'          => 0,
	},
	PREREQ_PM          => {
		'Scalar::Util'        => 0,
		'Time::Local'         => 0,
		'Exporter'            => 0,
	},
	AUTHOR             => 'Mons Anderson <mons@cpan.org>',
);
