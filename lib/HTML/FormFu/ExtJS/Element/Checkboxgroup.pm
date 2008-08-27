package HTML::FormFu::ExtJS::Element::Checkboxgroup;

use base "HTML::FormFu::ExtJS::Element::_Group";

use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self  = shift;
	
	my $data = $class->_items($self);
	my $super = $class->SUPER::render($self);
	return { %{$super}, xtype => "checkboxgroup", items => $data };
}
1;
