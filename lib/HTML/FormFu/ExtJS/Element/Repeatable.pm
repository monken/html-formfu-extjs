package HTML::FormFu::ExtJS::Element::Repeatable;


use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	return @{$self->form->_render_items($self)};
}

1;