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
	
	$super->{store} = \"$super->{store}" if($super->{store} && ref $super->{store} ne "SCALAR");
	
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

The value of C<store> will always be unquoted. You can either provide a variable name which points to an instance
of an C<Ext.data.Store> class or create the instance right away.

=head2 Remote Store

If you want to load the values of the combo box from an URL you have to create an C<Ext.data.Store> instance:

    var dataStore = new Ext.data.JsonStore({
        url: '/get_data',
        root: 'rows',
        fields: ["text", "id"]
    });
    
C</get_data> has to return a data structure like this:
    
    {
       "rows" : [
          {
             "text" : "Item #1",
             "value" : "1234"
          }
       ]
    }
    
To add that store to your Select field, the configuration has to look like this:

  - type: Select
    name: combo
    attrs:
      store: dataStore
    
You can also overwrite the field names for C<valueField> and C<displayField> by adding them to the C<attrs>:

    - type: Select
      name: combo
      attrs:
        store: dataStore
        valueField: title
        displayField: id

Make sure that the store is loaded before you call C<form.load()> on that form. Otherwise the combo box field cannot
resolve the value to the corresponding label.

=head1 SEE ALSO

L<HTML::FormFu::Element::Text>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut