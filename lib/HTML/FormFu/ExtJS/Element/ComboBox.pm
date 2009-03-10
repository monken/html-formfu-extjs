package HTML::FormFu::ExtJS::Element::ComboBox;

use base "HTML::FormFu::ExtJS::Element::Select";

use strict;
use warnings;
use utf8;

use JavaScript::Dumper;

sub render {
    my $class = shift;
    my $self  = shift;
    my $super = $class->SUPER::render($self);
    my $data;
    foreach my $option ( @{ $self->options } ) {
        push( @{$data}, [ $option->{value}, $option->{label} ] );
        if ( $option->{group} && ( my @groups = @{ $option->{group} } ) ) {
            foreach my $item (@groups) {
                push( @{$data}, [ $item->{value}, $item->{label} ] );
            }
        }
    }
    my $string = js_dumper( { fields => [ "value", "text" ], data => $data } );
    return {
        %{$super},

        editable => \1,
        store    => \( "new Ext.data.SimpleStore(" . $string . ")" ),
    };

}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::ComboBox - An editable select box

=head1 DESCRIPTION

Creates an editable select box.

The default ExtJS setup is:

  "mode"           : "local",
  "editable"       : true,
  "displayField"   : "text",
  "valueField"     : "value",
  "autoWidth"      : false,
  "forceSelection" : true,
  "triggerAction"  : "all",
  "store"          : new Ext.data.SimpleStore( ... ),
  "xtype"          : "combo"


=head1 SEE ALSO

L<HTML::FormFu::Element::Select>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
