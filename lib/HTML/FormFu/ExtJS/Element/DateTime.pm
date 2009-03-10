package HTML::FormFu::ExtJS::Element::DateTime;
use base "HTML::FormFu::ExtJS::Element::Multi";

use strict;
use warnings;
use utf8;


sub render {
	my $class = shift;
	my $self  = shift;
	$self->process;
	my @value;
	for(1..3) {
		push(@value, sprintf("%02d", $self->get_element->default));
		$self->remove_element( $self->get_element );
	}
	for(0..1) {
		$self->get_elements->[$_]->attrs({width => 50});
	}
	my $date = $self->form->element({type => "Date", value => join('-', @value)});
	$self->insert_before($date, $self->get_element);
	my $super = $class->SUPER::render($self);
	return $super;
}

sub record {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::record($self);
	return {%{$super}, type => "date", dateFormat => 'Y-m-d G:i'}
}

sub column_model {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::column_model($self);
	my $format = $self->attrs->{format_date} || $self->attrs_xml->{format_date} || 'Y-m-d G:i';
	return {%{$super}, renderer => \('Ext.util.Format.dateRenderer("'.$format.'")') }
}

1; 

__END__

=head1 NAME

HTML::FormFu::ExtJS::Element::DateTime - DateTime element

=head1 DESCRIPTION

You cannot put this element in a multi element because it is one itself.

=head2 column_model

To change the format of the date object specify C<< $element->attrs->{format_data} >>.
The date parsing and format syntax is a subset of PHP's date() function.
See L<http://extjs.com/deploy/dev/docs/?class=Date> for details.
It defaults to C<Y-m-d G:i> (which is the same as Perl's C<%Y-%m-%d %R>).


=head1 SEE ALSO

L<HTML::FormFu::Element::DateTime>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut