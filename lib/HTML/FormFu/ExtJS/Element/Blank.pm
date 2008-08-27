package HTML::FormFu::ExtJS::Element::Blank;


use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	my %attrs = $self->form->_get_attributes($self);
	my $html;
	if($attrs{html}) {
		$html = $attrs{html};
	} elsif ($self->name) {
		$html = $self->{name};
	} else {
		$html = "&nbsp;";
	}
	return {html => $html };
	
	
}

1;