package Test::QUnit::Bridge;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(tab tab_index bridge));

use Carp::Clan qw(croak);


sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        $self = bless {%{$_[0]}}, $class;
    } else {
        $self = bless {@_}, $class;
    }

    return $class->SUPER::new($self);
}


sub inject_bridge {
    my ($self, $repl) = @_;
    croak("Please override this method");
}

sub inject_select_test_window_function {
    my ($self, $js) = @_;
    croak("Please override this method");
}

sub inject_select_onload_window_function {
    my ($self, $js) = @_;
    croak("Please override this method");
}

sub inject_onload_function {
    my ($self, $js) = @_;
    croak("Please override this method");
}

sub run_qunit {
    my ($self, $url) = @_;
    croak("Please override this method");
}


1;
