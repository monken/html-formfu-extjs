package HTML::FormFu::ExtJS::Element::Hidden;

use base "HTML::FormFu::ExtJS::Element::_Field";


sub render {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::render($self);
	return { %{$super}, xtype => "hidden" };
	
	
}

1;