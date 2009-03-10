package HTML::FormFu::ExtJS::Element::Select;

use base "HTML::FormFu::ExtJS::Element::_Group";

use strict;
use warnings;
use utf8;

use JavaScript::Dumper;

sub render {
	my $class = shift;
	my $self  = shift;
	my $super = $class->SUPER::render($self);

	my $data;
	foreach my $option ( @{ $self->render_data->{options} } ) {
		push( @{$data}, [ $option->{value}, $option->{label} ] );
		if($option->{group} && (my @groups = @{$option->{group}})) {
			foreach my $item (@groups) {
				push(@{$data}, [$item->{value},$item->{label}]);
			}
		}
	}
	my $string = js_dumper( { fields => [ "value", "text" ], data => $data } );
    return {
		mode           => "local",
		editable       => \0,
		displayField   => "text",
		valueField     => "value",
		hiddenName     => $self->name,
		autoWidth      => \0,
		forceSelection => \1,
		triggerAction  => "all",
		store          => \( "new Ext.data.SimpleStore(" . $string . ")" ),
		xtype          => "combo",
		%{$super}
	};

}



1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Select - Select box

=head1 DESCRIPTION

Creates a select box.

The default ExtJS setup is:

  "mode"           : "local",
  "editable"       : false,
  "displayField"   : "text",
  "valueField"     : "value",
  "autoWidth"      : false,
  "forceSelection" : true,
  "triggerAction"  : "all",
  "store"          : new Ext.data.SimpleStore( ... ),
  "xtype"          : "combo"

This acts like a standard html select box. If you want a more ajaxish select box (e.g. editable) you can override these values with L</attrs|HTML::FormFu>.

=head1 SEE ALSO

L<HTML::FormFu::Element::Text>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut