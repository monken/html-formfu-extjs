package HTML::FormFu::ExtJS::Element::_Field;

use strict;
use warnings;
use utf8;

use HTML::FormFu::Util qw(
    xml_escape
);
use HTML::FormFu::ExtJS::Util qw(
    _camel_case
    _css_case
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
		defined $self->default ? (value => $value) : (),
		$parent->_get_attributes($self)
	};
}


=head2 record

C<record> returns a HashRef with contains all informations to create a record
field from this field element.

  $class->record( $element, { force_type => 'int', defaultValue => 10 } );

The arguments hash understands:

= head3 only_name
Use just the elements name, not it's nested name.
This is needed for custom clientside processing of repeatable elements.

= head3 force_type
Used to set an other record field type, than the default 'string'.

= head3 defaultValue
Used to set the default value in the record field.

=cut

sub record {
	my $class = shift;
	my $self = shift;
    my %args = (
        only_name  => 0,
        force_type => undef,
        defaultValue => undef,
        @_
    );

	my $name = $args{only_name} ? $self->name : $self->nested_name;
    return {
        name    => _camel_case($name),
        mapping => $name,
        type    => (defined $args{force_type} && length $args{force_type}) ? $args{force_type} : "string",
        (defined $args{defaultValue}) ? (defaultValue => $args{defaultValue}) : ()
    };
}


=head2 column_model

C<column_model> returns a HashRef with contains all informations to create an
entry for a column model from this field element.

  $class->column_model( $element, { only_name => 1 } );

All attributes that were given to the element configuration are added to the
column model:

  - type: Text
    attrs:
      width: 150


The arguments hash understands:

= head3 only_name
Use just the elements name, not it's nested name.
This is needed for custom clientside processing of repeatable elements.

=cut

sub column_model {
	my $class = shift;
	my $self = shift;
    my %args = (
        only_name => 0,
        @_
    );
    my $parent = $self->can("_get_attributes") ? $self : $self->form;

	my $data_index = $args{only_name} ? $self->name : $self->nested_name;

    return {
        id        => _css_case($data_index),
        dataIndex => _camel_case($data_index),
        header    => scalar $self->label || scalar $self->name,
        $parent->_get_attributes($self)
    };
}

1;
