package HTML::FormFu::ExtJS::Element::Date;

use base "HTML::FormFu::ExtJS::Element::_Field";

sub render {
	my $class = shift;
	my $self = shift;
	$self->_date_defaults;
	$self->default(sprintf("%04s-%02s-%02s", $self->year->{default},$self->month->{default},$self->day->{default}))
	if($self->year->{default} && $self->month->{default} && $self->day->{default});
	
	my $super = $class->SUPER::render($self);
	return { %{$super}, xtype => "datefield" };
	
	
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Text - Text element

=head1 DESCRIPTION

Simple text element.

=head1 SEE ALSO

L<HTML::FormFu::Element::Text>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut