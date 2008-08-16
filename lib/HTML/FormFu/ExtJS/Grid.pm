package HTML::FormFu::ExtJS::Grid;

use base "HTML::FormFu::ExtJS";

use strict;
use warnings;



sub ext_data_reader {
	my $form = shift;
	my @add  = @_;
	my $data;
	for ( @{ $form->ext_columns() } ) {
		push( @{$data}, { name => $_->name } )
		  if ( $_->can("name") && $_->name );
	}
	for (@add) {
		push( @{$data}, { name => $_ } );
	}
	return js_dumper($data);
}

sub ext_grid_data {
	my $self = shift;
	my $data = shift;
	use DBIx::Class::ResultClass::HashRefInflator;
	if ( ref $data eq "DBIx::Class::ResultSet" ) {

		#$data->result_class('DBIx::Class::ResultClass::HashRefInflator');
		my @data = $data->all;
		$data = \@data;
	}
	my @return;
	my @all_elements = @{ $self->get_all_elements() };
	my ( %element_cache, %deflator_cache, %options_cache );
	foreach my $datum ( @{$data} ) {
		my $obj;
		foreach my $column (@all_elements) {
			next if ( $column->type =~ /submit/i );
			my $name = $column->name;
			my $element = $element_cache{$name} || $self->get_element($name);
			$element_cache{$name} ||= $element;
			next unless ($element);
			$obj->{$name} = $datum->$name;
			my $deflators = $deflator_cache{$name} || $element->get_deflators;
			$deflator_cache{$name} ||= $deflators;

			foreach my $deflator ( @{$deflators} ) {

				$obj->{$name} = $deflator->deflator( $obj->{$name} );
			}
			my $can_options = $options_cache{$name}
			  || $element->can("_options");
			$options_cache{$name} ||= $element->can("_options");
			if ($can_options) {
				my @options = @{ $element->_options };
				my @option = grep { $_->{value} eq $obj->{$name} } @options;
				$obj->{$name} = $option[0]->{label};
			}
		}
		push( @return, $obj );
	}
	return \@return;
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Grid

=head1 DESCRIPTION

Nothing here yet.

=head1 SEE ALSO

L<HTML::FormFu::ExtJS>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut