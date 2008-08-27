package HTML::FormFu::ExtJS::Element::Password;

use base "HTML::FormFu::ExtJS::Element::Text";

use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::render($self);
	return { %{$super}, inputType => "password" };
	
	
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Password - Password element

=head1 DESCRIPTION

Simple password element.

=head1 SEE ALSO

L<HTML::FormFu::Element::Password>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut