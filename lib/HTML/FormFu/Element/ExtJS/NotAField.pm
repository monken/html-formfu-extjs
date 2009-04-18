package HTML::FormFu::Element::ExtJS::NotAField;

use strict;
use base 'HTML::FormFu::Element::_Input';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    # force read only
    $self->model_config->{read_only} = 1;

    return $self;
}

sub string {
    my ( $self, $args ) = @_;

    return '';
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::ExtJS::NotAField - Not a form field, just to transport values

=head1 SYNOPSIS

    my $e = $form->element( ExtJS::NotAField => 'foo' );

=head1 DESCRIPTION

Not a form field, just to transport values

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Mario Minati, C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
