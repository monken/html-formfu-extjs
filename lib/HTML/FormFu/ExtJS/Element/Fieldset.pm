package HTML::FormFu::ExtJS::Element::Fieldset;

sub render {
	my $class = shift;
	my $self = shift;
	return { items => $self->form->_render_items($self), title => $self->legend, autoHeight => 1, xtype => "fieldset" };
	
}

1;