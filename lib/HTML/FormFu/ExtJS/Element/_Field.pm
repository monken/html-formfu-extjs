package HTML::FormFu::ExtJS::Element::_Field;

use strict;
use warnings;
use utf8;

use HTML::FormFu::Util qw(
    xml_escape
);


sub render {
	my $class  = shift;
	my $self   = shift;
	my $parent = $self->can("_get_attributes") ? $self : $self->form;
	my $value = $self->default;
	map { $value = $_->process($value) } @{$self->get_deflators};

	return {
		fieldLabel => xml_escape( $self->label ),
		hideLabel  => $self->label ? \0 : \1,
		(scalar $self->id) ? (id => scalar $self->id) : (),
		$self->nested_name ? (name => $self->nested_name) : (),
		$self->default ? (value => $value) : (),
		$parent->_get_attributes($self)
	};
}

sub record {
	my $class = shift;
	my $self = shift;
	my $name = $self->nested_name;
	return {name => $class->_camel_case($name), mapping => $self->nested_name, type => "string"};
}

sub column_model {
	my $class = shift;
	my $self = shift;
	my $data_index = $self->nested_name;
	return { id => $class->_css_case($data_index), dataIndex => $class->_camel_case($data_index), header => scalar $self->label || scalar $self->name };
}


sub _camel_case {
    my $self = shift;
    return lcfirst(join('', map { ucfirst($_) } split(/\./, $_[0])));
}

sub _css_case {
    my $self = shift;
    my $data_index = shift;
	$data_index =~ s/\./-/g;
	return $data_index;
}

1;
