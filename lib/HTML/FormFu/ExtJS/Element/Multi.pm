package HTML::FormFu::ExtJS::Element::Multi;
use base "HTML::FormFu::ExtJS::Element::_Field";

use strict;
use warnings;
use utf8;


sub render {
	my $class = shift;
	my $self  = shift;
	
	my $super = $class->SUPER::render($self);
	my @elements;
	push( @elements, @{ $self->form->_render_items($self) } );
	unshift(@elements, { fieldLabel => $self->label, xtype => "textfield", hidden => \1})
	  if($self->label);
	my $data;
	my $width = $self->label ? 1 / @elements : 1 / (@elements);
	foreach my $i ( 0 .. @elements ) {
		my $empty_field = ($i == 0 && $self->label) ? 1 : 0;
		my %width = ();
		if($super->{individualWidth} && !$empty_field) {
			my $width = $super->{individualWidth}->[$i-($self->label?1:0)];
			%width =  (width => $width) if($width);
		} elsif($super->{individualColumnWidth} && !$empty_field) {
			my $width = $super->{individualColumnWidth}->[$i-($self->label?1:0)];
			%width =  (columnWidth => $width) if($width);
		}
		my $column =
		  { $empty_field ? () : %{$super}, 
		  	%width,
		  	layout => "form", items => [ $elements[$i] ] };
		push( @{$data}, $column );
	}
	pop( @{$data} );
	return { layout => "form", items => [ { layout => "column", items => $data } ] };
}
1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Multi - Multi column

=head1 DESCRIPTION

This element creates a row of elements specified in C<elements>. 
There are many ways to influence the layout of this element:

=head2 width

  - type: Multi
    label: Multi element
    attrs:
      width: 100
      
Specifies the width of each column

=head2 individualWidth

  - type: Multi
    label: Multi element
    attrs:
      individualWidth: [100, 200]
    elements:
      - type: Text
        label: 1st
      - type: Text
        label: 2nd
      
Sets the individual width of the items in pixels.

=head2 individualColumnWidth

  - type: Multi
    label: Multi element
    attrs:
      individualWidth: [.2, .3]
    elements:
      - type: Text
        label: 1st
      - type: Text
        label: 2nd
      
Specifies the relative width of the columns.


Each attribute specified in C<attrs> gets passed to each column.
This way you can change e.g. the label separator and label width:

  - type: Multi
    label: Appointment
    attrs:
      defaults:
        width: 50
      width: 150
      labelWidth: 35
      layoutConfig:
        labelSeparator:  .:.
    elements:
      - type: Text
        name: r11
        label: Date
      - type: Text
        name: r2
        label: Time
      - type: Checkbox
        label: st

=head1 SEE ALSO

L<HTML::FormFu::Element::Multi>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
