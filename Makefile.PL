use inc::Module::Install;
name 'Test-QUnit';
all_from 'lib/Test/QUnit.pm';
readme_from 'lib/Test/QUnit.pm';
readme_markdown_from 'lib/Test/QUnit.pm';
readme_pod_from 'lib/Test/QUnit.pm';
githubmeta;

requires 'Test::Builder::Module';
requires 'MozRepl';
requires 'MozRepl::RemoteObject';
requires 'Time::HiRes';
requires 'Data::Util';
requires 'Class::Accessor::Fast';
requires 'Carp::Clan';
requires 'UNIVERSAL::require';

test_requires 'Test::More' => '0.94';
test_requires 'Plack::App::Directory';
test_requires 'Plack::Runner';
test_requires 'Data::Util';

tests 't/*.t';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
