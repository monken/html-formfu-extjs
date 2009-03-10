package HTML::FormFu::ExtJS::Element::_Field;

use strict;
use warnings;
use utf8;

sub render {
	my $class  = shift;
	my $self   = shift;
	my $parent = $self->can("_get_attributes") ? $self : $self->form;
	my $value = $self->default;
	map { $value = $_->process($value) } @{$self->get_deflators};
	return {
		fieldLabel => $self->label,
		hideLabel  => $self->label ? \0 : \1,
		id         => scalar $self->id,
		$self->nested_name ? (name => $self->nested_name) : (),
		$self->default ? (value => $value) : (),
		$parent->_get_attributes($self)
	};
}

sub record {
	my $class = shift;
	my $self = shift;
	my $name = $self->nested_name;
	$name =~ s/\./-/g;
	return {name => $name, mapping => $self->nested_name, type => "string"};
}

sub column_model {
	my $class = shift;
	my $self = shift;
	my $data_index = $self->nested_name;
	$data_index =~ s/\./-/g;
	return { id => $data_index, dataIndex => $data_index, header => scalar $self->label || scalar $self->name };
}

1;
