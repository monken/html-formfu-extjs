package HTML::FormFu::ExtJS::Element::ContentButton;

use base "HTML::FormFu::ExtJS::Element::_Field";

use strict;
use warnings;

sub render {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::render($self);
	return {  };
	
	
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Image - Image element

=head1 DESCRIPTION

Insert an image specified in C<src>.

=head1 SEE ALSO

L<HTML::FormFu::Element::Image>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut