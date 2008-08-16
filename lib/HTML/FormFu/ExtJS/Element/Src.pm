package HTML::FormFu::ExtJS::Element::Src;


sub render {
	my $class = shift;
	my $self = shift;
	return {html => $self->content };
	
	
}

1;