use inc::Module::Install;
name 'Test-QUnit';
all_from 'lib/Test/QUnit.pm';
readme_from 'lib/Test/QUnit.pm';
readme_markdown_from 'lib/Test/QUnit.pm';
readme_pod_from 'lib/Test/QUnit.pm';
githubmeta;

requires 'MozRepl';
requires 'MozRepl::RemoteObject';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
