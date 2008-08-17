package HTML::FormFu::ExtJS::Element::_Field;

sub render {
	my $class  = shift;
	my $self   = shift;
	my $parent = $self->can("_get_attributes") ? $self : $self->form;
	return {
		fieldLabel => $self->label,
		hideLabel  => $self->label ? \0 : \1,
		id         => scalar $self->id,
		$self->nested_name ? (name => $self->nested_name) : (),
		$self->default ? (value => $self->default) : (),
		$parent->_get_attributes($self)
	};
}
1;
