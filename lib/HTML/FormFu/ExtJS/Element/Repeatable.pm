package HTML::FormFu::ExtJS::Element::Repeatable;


sub render {
	my $class = shift;
	my $self = shift;
	return @{$self->form->_render_items($self)};
}

1;