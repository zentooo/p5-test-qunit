package Test::QUnit;
use strict;
use warnings;
our $VERSION = '0.03';

binmode(STDOUT, ":utf8");

use base qw(Test::Builder::Module);

use Plack::App::Directory;
use Plack::Runner;
use File::Basename;
use UNIVERSAL::require;

use Test::QUnit::Bridge::MozRepl;

our @EXPORT = qw(qunit_ok qunit_local inject_bridge select_test_window select_onload_window onload);

my %bridges;
my $bridge = Test::QUnit::Bridge::MozRepl->new;
$bridges{'MozRepl'} = $bridge;

my $builder = __PACKAGE__->builder;


sub qunit_ok($;$) {
    my ($url, $msg) = @_;

    my $message = $msg || '';

    my $tap_result = $bridge->run_qunit($url);

    $builder->subtest($message => sub {
        for my $result (@$tap_result) {
            $builder->ok($result->{success}, $result->{message});
        }
        $builder->done_testing;
    });
}

sub qunit_local($;$) {
    my ($html_file_path, $msg) = @_;

    my $pid = fork;
    my ($base_name, $dir) = fileparse($html_file_path);

    if ( $pid ) {
      sleep(1);
      qunit_ok('http://localhost:8080/' . $base_name, $msg);
      kill 'KILL', $pid;
    }
    else {
      my $app = Plack::App::Directory->new( +{ root => $dir } )->to_app;
      Plack::Runner->new()->run($app);
    }
}

sub inject_bridge {
    my ($name, $imple) = @_;

    if ( exists $bridges{$name} ) {
        $bridge = $bridges{$name};
        $bridge->inject_bridge($imple);
    }
    else {
        my $module_name = "Test::QUnit::Bridge::$name";
        $module_name->require;
        no strict 'refs';
        $bridge = $module_name->new;
        $bridge->inject_bridge($imple);
        $bridges{$name} = $bridge;
    }
}

sub select_test_window {
    $bridge->inject_select_test_window_function(shift);
}

sub select_onload_window {
    $bridge->inject_select_onload_window_function(shift);
}

sub onload {
    $bridge->inject_onload_function(shift);
}

1;
__END__

=head1 NAME

Test::QUnit - Yet Another Testing Framework for QUnit.

=head1 SYNOPSIS

  use Test::QUnit;

  qunit_ok('http://path/to/qunit/test.html', 'description');

=head1 DESCRIPTION

Test::QUnit is testing framework to run QUnit test suites with prove, via MozRepl.

=head1 AUTHOR

zentooo E<lt>ankerasoy@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE


Test::QUnit

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


QUnit

The MIT License

Copyright (c) 2009 John Resig, Jörn Zaefferer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=cut
