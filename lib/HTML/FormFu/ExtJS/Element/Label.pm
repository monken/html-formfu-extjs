package HTML::FormFu::ExtJS::Element::Label;

use strict;
use warnings;
use utf8;


sub render {
	my $class = shift;
	my $self = shift;

    my $parent = $self->can("_get_attributes") ? $self : $self->form;

    my $value = $self->default;
    map { $value = $_->process($value) } @{$self->get_deflators};

	return {
        xtype => "label",
        (scalar $self->id) ? (id => scalar $self->id) : (),
        $self->nested_name ? (name => $self->nested_name) : (),
        cls   => 'x-form-item',                         # adjust label height
        text  => $value,
        $parent->_get_attributes($self)
    };
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Text - Text element

=head1 DESCRIPTION

Simple text element.

=head1 SEE ALSO

L<HTML::FormFu::Element::Text>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut