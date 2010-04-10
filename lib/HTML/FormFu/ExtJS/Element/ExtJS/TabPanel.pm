package HTML::FormFu::ExtJS::Element::ExtJS::TabPanel;
our $VERSION = '0.075';

use strict;
use warnings;
use utf8;

use HTML::FormFu::Util qw(
    xml_escape
);


# Their is only point in check Number and Boolean fields are what they are meant to be
# Does not check attribites inheritted e.g. width


sub render {
	my $class  = shift;
	my $self   = shift;

	my $parent = $self->can("_get_attributes") ? $self : $self->form;
	my %attrs  = $parent->_get_attributes($self);

	$attrs{'activeTab'}=0 if (!defined($attrs{'activeTab'}));

	# Check that each one is corret type for a TabPanel
	foreach my $k ('animScroll','autoTabs','enableTabScroll','layoutOnTabChange','plain','resizeTabs') {
		warn "$k not boolean (0,1,true,false)" if (defined($attrs{$k}) && $attrs{$k} !~ /^[01]$|^true$|^false$/);
	}
	foreach my $k ('activeTab','minTabWidth','scrollIncrement','scrollRepeatInterval','tabMargin') {
		warn "$k not a integer $class" if (defined($attrs{$k}) && $attrs{$k} !~ /^[+-]?[0-9]*$/);
	}

	foreach my $k ('scrollDuration') {
		warn "$k not a float" if (defined($attrs{$k}) && $attrs{$k} !~ /^[+-]?[0-9.]*$/);
	}

	
	return {
		xtype => $self->xtype,
		(scalar $self->id) ? (id => scalar $self->id) : (),
        items => $self->form->_render_items( $self ),
		%attrs
	};
}

1;

__END__

=head1 NAME

HTML::FormFu::ExtJS::Element::ExtJS::TabPanel -  FormFu class for ExtJS tab panels

=head1 VERSION

version 0.075

=head1 DESCRIPTION

FormFu class for ExtJS tab panels.

=head1 SEE ALSO

The ExtJS specific stuff is in L<HTML::FormFu::Element::ExtJS::TabPanel>

=head1 AUTHOR

Damon Atkins
Based on HTML::FormFu::ExtJS::Element::ExtJS::Panel 

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

