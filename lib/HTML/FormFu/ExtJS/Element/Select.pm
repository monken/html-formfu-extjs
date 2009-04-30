package HTML::FormFu::ExtJS::Element::Select;

use base "HTML::FormFu::ExtJS::Element::_Group";

use strict;
use warnings;
use utf8;
use Carp;

use JavaScript::Dumper;

sub render {
	my $class = shift;
	my $self  = shift;
	my $super = $class->SUPER::render($self);

    my $attrs = {};

    my $url = $super->{url};

    if($url && !$super->{id}) {
        carp 'Cannot create remote store without an field id';
        delete $super->{url};
    }

    if ($super->{store} && ref $super->{store} ne "SCALAR") {
	    $super->{store} = \"$super->{store}";
    } elsif ($super->{url}) {
        $attrs->{hiddenValue} = $self->default;
        $super->{value} = $super->{loading} || 'Loading...';
        delete $super->{loading};
        $attrs->{mode} = "remote";
        $super->{store} = \"new Ext.data.SimpleStore({
            fields:['value','text'],
            id:0,
            autoLoad:true,
            proxy:new Ext.data.HttpProxy({
                url:'$url',
                method:'GET',
                disableCaching:false
            }),
            listeners:{
                load:function(store, records, options) {
                    var combobox = Ext.getCmp('$super->{id}');
                    var hiddenfield = combobox.hiddenField;
                    var value = hiddenfield.value;
                    if (value && (record = store.getById(value))) {
                        combobox.setValue(record.data.text);
                    }
                    else {
                        combobox.setValue('');
                    }
                },
                loadexception:function(store, options, response, error) {
                    var combobox = Ext.getCmp('$super->{id}');
                    combobox.setValue('');
                    combobox.markInvalid(error || response.statusText);
                }
            }
        })";
        delete $super->{url};
    } else {
        $attrs->{mode} = "local";
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
        $super->{store} = \"new Ext.data.SimpleStore(" . $string . ")";
    }

    return {
		editable       => \0,
		displayField   => "text",
		valueField     => "value",
		hiddenName     => $self->name,
		autoWidth      => \0,
		forceSelection => \1,
		triggerAction  => "all",
		xtype          => "combo",
		%{$super},
        %{$attrs}
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

If you want to load the values of the combo box from an URL you can either create your own C<Ext.data.Store> instance
or let this class handle this.

=head3 Built-in remote store

  - type: Select
    name: combo
    id: unique_identifier
    attrs:
      url: /get_data

This will create a remote store instance which will fetch the data from C<url>. Make sure you give the 
select field an unique id. Otherwise the store will not be attached and a warning is thrown.

You can customize the text which is shown while the store is being loaded. It defaults to C<Loading...> and 
can be changed by setting the C<loading> attribute:

- type: Select
  name: combo
  id: unique_identifier
  attrs:
    url: /get_data
    loading: Wird geladen...


=head3 Custom C<Ext.data.Store> instance

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

=head1 AUTHORS

Moritz Onken (mo)

Alexander Hartmaier (abraxxa)

=head1 COPYRIGHT & LICENSE

Copyright 2009 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
