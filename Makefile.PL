use inc::Module::Install;
name 'Test-QUnit';
all_from 'lib/Test/QUnit.pm';
readme_from 'lib/Test/QUnit.pm';
readme_markdown_from 'lib/Test/QUnit.pm';
readme_pod_from 'lib/Test/QUnit.pm';
githubmeta;


requires 'Test::Builder::Module';
requires 'Test::TCP';

requires 'MozRepl';
requires 'MozRepl::RemoteObject';

requires 'Plack::App::Directory';
requires 'Plack::Loader';

requires 'Data::Util';
requires 'Class::Accessor::Fast';
requires 'Path::Class';

requires 'Carp::Clan';
requires 'Time::HiRes';
requires 'Try::Tiny';
requires 'UNIVERSAL::require';


test_requires 'Test::More' => '0.94';
test_requires 'Test::TCP';

test_requires 'Plack::App::Directory';
test_requires 'Plack::Loader';

test_requires 'Data::Util';


tests 't/*.t';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
