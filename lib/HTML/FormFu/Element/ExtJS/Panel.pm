package HTML::FormFu::Element::ExtJS::Panel;

use strict;
use base 'HTML::FormFu::Element::Block';
use Class::C3;

__PACKAGE__->mk_item_accessors( qw( xtype ) );

__PACKAGE__->mk_output_accessors( qw( title label ) );


sub new {
    my $self = shift->next::method(@_);

    $self->xtype( 'panel' );

    return $self;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->next::method( {
        title => $self->title,
        label => $self->label,
        xtype => $self->xtype,
        $args ? %$args : (),
    } );

    return $render;
}


# A special ExtJS Element, so no output in HTML forms

sub string {
    my ( $self, $args ) = @_;
    warn "Stringification is not supported for " . __PACKAGE__;

    return '';
}

sub tt {
    my ( $self, $args ) = @_;
    warn "Stringification is not supported for " . __PACKAGE__;

    return '';
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Panel - FormFu class for ExtJS panels

=head1 DESCRIPTION

FormFu class for ExtJS panels.

=head1 METHODS

=head2 xtype
Defaults to 'panel'

=head2 title, label
Sets the title attribute of a panel.
If both are given title has the higher priority.

=head1 SEE ALSO

The ExtJS specific stuff is in L<HTML::FormFu::ExtJS::Element::ExtJS::Panel>

=head1 AUTHOR

Mario Minati, C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
