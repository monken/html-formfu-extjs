package HTML::FormFu::ExtJS::Element::Hr;

use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	return { html => "<hr>" };
	
	
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Hr - Horizontal line

=head1 DESCRIPTION

Renders a horizontal line.

=head1 SEE ALSO

L<HTML::FormFu::Element::Hr>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut