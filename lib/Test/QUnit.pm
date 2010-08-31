package Test::QUnit;
use strict;
use warnings;
our $VERSION = '0.01';

binmode(STDOUT, ":utf8");

use base qw(Test::Builder::Module);
use UNIVERSAL::require;
use Test::QUnit::Bridge::MozRepl;

our @EXPORT = qw(qunit_ok inject_bridge inject_select_window_function inject_onload_function);

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

sub inject_bridge {
    my ($name, $imple) = @_;

    if ( $bridges{$name} ) {
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

sub inject_select_window_function {
    $bridge->inject_select_window_function(shift);
}

sub inject_onload_function {
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

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
