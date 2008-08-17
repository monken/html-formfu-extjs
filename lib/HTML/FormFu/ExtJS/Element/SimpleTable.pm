package HTML::FormFu::ExtJS::Element::SimpleTable;
use strict;
use warnings;

sub render {
	my $class = shift;
	my $self  = shift;
	my @header;
	my @rows;
	foreach my $element ( @{ $self->get_elements } ) {
		foreach my $row ( @{ $element->get_elements } ) {
			if ( $row->tag eq "th" ) {
				push(
					@header,
					{
						xtype  => 'label',
						text   => $row->{content},
						cls    => 'x-form-check-group-label',
						anchor => '-15',
					}
				);
			} elsif ( $row->tag eq "td" ) {
				push( @rows, @{ $self->form->_render_items($row) } );
			}
		}
	}
	my $data;
	my $width = 1 / @header;
	foreach my $i ( 0 .. @header ) {
		my $column = { columnWidth => $width, layout => "form", items => [ $header[$i] ] };
		foreach my $j ( 0 .. @rows - 1 ) {
			next unless ( $j % @header == $i );
			push( @{ $column->{items} }, $rows[$j] );
		}
		push( @{$data}, $column );
	}
	pop( @{$data} );
	return { layout => "column", items => $data };
}
1;


=head1 NAME

HTML::FormFu::ExtJS::Element::SimpleTable - Simple table layout

=head1 DESCRIPTION

This element renders a simple table using ExtJS column layout. There is no
way to influence the width etc. of each column. They get distributed equally.

To create layouts with individual width and styles see L<HTML::FormFu::ExtJS::Element::Multi>.

=head1 SEE ALSO

L<HTML::FormFu::Element::Multi>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
