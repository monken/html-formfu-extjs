package HTML::FormFu::ExtJS::Element::Multi;
use base "HTML::FormFu::ExtJS::Element::_Field";
use strict;
use warnings;

sub render {
	my $class = shift;
	my $self  = shift;
	my @elements;
	push( @elements, @{ $self->form->_render_items($self) } );
	my $data;
	my $width = 1 / @elements;
	foreach my $i ( 0 .. @elements ) {
		my $column =
		  { 
		  	#columnWidth => $width,
		  	layout => "form", items => [ $elements[$i] ] };
		push( @{$data}, $column );
	}
	pop( @{$data} );
	my $super = $class->SUPER::render($self);
	return { layout => "form", %{$super}, items => [ { layout => "column", items => $data } ] };
}
1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Multi - Multi column

=head1 DESCRIPTION


=head1 SEE ALSO

L<HTML::FormFu::Element::Multi>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
