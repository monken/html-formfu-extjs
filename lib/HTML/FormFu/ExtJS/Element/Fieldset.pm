package HTML::FormFu::ExtJS::Element::Fieldset;

use strict;
use warnings;
use utf8;

use HTML::FormFu::Util qw(
    xml_escape
);

sub render {
	my $class = shift;
	my $self = shift;

    my $title = $self->legend;
    my $parent = $self->can("_get_attributes") ? $self : $self->form;

	return {
        items       => $self->form->_render_items( $self ),
        $title ? (title => xml_escape( $title )) : (),
        autoHeight  => 1,
        xtype       => "fieldset",
        $parent->_get_attributes( $self )
    };
}

1;