package HTML::FormFu::ExtJS;
use base HTML::FormFu;
use strict;
use warnings;
use Scalar::Util qw/ weaken /;
use Carp qw/ croak carp /;
use utf8;
use JavaScript::Dumper;
use Tie::Hash::Indexed;
use Hash::Merge::Simple qw(merge);
use Scalar::Util 'blessed';
use Data::Dumper;
our $VERSION = '0.03008';
$VERSION = eval $VERSION;    # see L<perlmodstyle>
use HTML::FormFu::Util qw/require_class/;

=head1 NAME

HTML::FormFu::ExtJS - Render and validate ExtJS forms using HTML::FormFu

=head1 DESCRIPTION

This module allows you to render ExtJS forms without changing your HTML::FormFu config file.

  use HTML::FormFu::ExtJS;
  my $form = new HTML::FormFu::ExtJS;
  $form->load_config_file('forms/config.yml');

  print $form->render;

HTML::FormFu::ExtJS subclasses HTML::FormFu therefore you can access all of its methods via C<$form>.

If you want to generate grid data and data records for ExtJS have a look at L<HTML::FormFu::ExtJS::Grid>.

This module requires ExtJS 2.2 or greater. Most of the elements work with ExtJS 2.0 or greater too.

=head1 EXAMPLES

Check out the examples in C<examples/html> (or try L<http://search.cpan.org/src/PERLER/HTML-FormFu-ExtJS-0.01/examples/html>).

=head1 METHODS

A HTML::FormFu::ExtJS object inherits all methods of a L<HTML::FormFu> object. There are some additional methods avaiable:

=head2 render

Returns a full ExtJS form panel. Usually you'll use this like this (L<TT|Template> example):

  var form = [% form.render %];

C<form> is now a JavaScript object of type C<Ext.FormPanel>. You might want to put a handler on the button so they will
trigger a function when clicked.

  Ext.getCmp("id-of-your-button").setHandler(function() { alert('clicked') } );

Or you can add the handler directly to your element:

  - type: Button
    value: Handler
    attrs:
      handler: function() { alert("click") }


=head2 grid_data

This methods returns data in a format which is expected by ExtJS as perl object. You will want to serialize it with L<JSON> and send it to the client.

  $form->grid_data($data);

C<$data> can be a L<DBIx::Class::ResultSet> object, an arrayref of L<DBIx::Class::Row> objects or a simple perl object which should look like this:

  $data = [{fieldname1 => 'value1', fieldname2 => 'value2'}];

The returned perl object looks something like this:

  {
          'metaData' => {
                        'fields' => [
                                    {
                                      'name' => 'artistid',
                                      'type' => 'string'
                                    },
                                    {
                                      'name' => 'name',
                                      'type' => 'string'
                                    }
                                  ],
                        'totalProperty' => 'results',
                        'root' => 'rows'
                      },
          'rows' => [
                    {
                      'artistid' => '1',
                      'name' => 'Caterwauler McCrae'
                    },
                    {
                      'artistid' => '2',
                      'name' => 'Random Boy Band'
                    },
                    {
                      'artistid' => '3',
                      'name' => 'We Are Goth'
                    }
                  ],
          'results' => 3
        }

The C<metaData> property does some kind of magic on the client side. Read L<http://extjs.com/deploy/dev/docs/?class=Ext.data.JsonReader> for more information.

Sometimes you need to send a different number of results back to the client than there are rows (i.e. paged grid view).
Therefore you can override every item of the perl object by passing a hashref.

  $form->grid_data($data, {results => 99});

This will set the number of results to 99.

=over

=item C<grid_data> will call all deflators specified in the form config file. 

=item L<Select|HTML::FormFu::ExtJS::Select> elements will not display the acutal value but the label of the option it refers to.

=item If you are passing L<DBIx::Class> objects and the field is a L<has_many|DBIx::Class::Relationship/has_many> or L<many_to_many|DBIx::Class::Relationship/many_to_many> relationship it will call C<count> on that.

=back

=cut


=head2 record

C<record> returns a JavaScript string which creates a C<Ext.data.Record> object from
the C<$form> object. This is useful if you want to create C<Ext.data.Record> objects
dynamically using JavaScript.

You can add more fields by passing them to the method.

  $form->record();
  # Ext.data.Record.create( [ {'name' => 'artistid', 'type' => 'string'},
  #                           {'name' => 'name', 'type' => 'string'} ] );
  
  $form->record( 'address', {'name' => 'age', type => 'date'} );
  # Ext.data.Record.create( [ {'name' => 'artistid', 'type' => 'string'},
  #                           {'name' => 'name', 'type' => 'string'},
  #                           {'name' => 'age', 'type' => 'date'},
  #                           'address' ] );

To get the inner arrayref as perl object, call C<< $form->_record() >>.

=cut

sub render {
	my $self = shift;
	return "new Ext.FormPanel(" . js_dumper( $self->_render(@_) ) . ");";
}

sub _render {
	my $self  = shift;
	my %param = @_;
	my %attrs = $self->_get_attributes($self);
	return {
		$self->action ? ( url => $self->action ) : (),
		items   => $self->_render_items,
		buttons => $self->_render_buttons,
		%param, %attrs
	};
}

=head2 render_items

This method returns all form elements in the JavaScript Object Notation (JSON). You can put this string
right into the C<items> attribute of your ExtJS form panel.

=head2 _render_items

Acts like L</render_items> but returns a perl object instead.

=cut

sub _render_items {
	my $self   = shift;
	my $from   = shift || $self;
	my $output = [];
	foreach my $element ( @{ $from->get_elements() } ) {
		next
		  if ( $element->type eq "Submit"
			|| $element->type eq "Button"
			|| $element->type eq "Reset"
			|| $element->type eq "ContentButton" );
		my $class = "HTML::FormFu::ExtJS::Element::" . $element->type;
		require_class($class);
		push( @{$output}, $class->render($element) );
	}
	return $output;
}

sub render_items {
	return js_dumper( shift->_render_items );
}

=head2 render_buttons

C<render_buttons> returns all buttons specified in C<$form> as a JSON string.
Put it right into the C<buttons> attribute of your ExtJS form panel.

=head2 _render_buttons

Acts like L</render_buttons> but returns a perl object instead.

=cut

sub render_buttons {
	my $self = shift;
	return js_dumper( $self->_render_buttons );
}

sub _render_buttons {
	my $self   = shift;
	my $from   = shift || $self;
	my $output = [];
	foreach my $element ( @{ $from->get_all_elements() } ) {
		next
		  unless ( $element->type eq "Submit"
			|| $element->type eq "Button"
			|| $element->type eq "ContentButton"
			|| $element->type eq "Reset" );
		my $class = "HTML::FormFu::ExtJS::Element::" . $element->type;
		require_class($class);
		push( @{$output}, $class->render($element) );
	}
	return $output;
}

# Altlasten
sub ext_items {
	my $self = shift;
	my @items;
	my %map_types = (
		Text     => "textfield",
		Checkbox => "checkbox",
		Textarea => "textarea",
		Date     => "datefield",
		Hidden   => "hidden",
		Radio    => "radio",
		Select   => "combo",
		Fieldset => "fieldset",
	);
	for ( @{ $self->get_elements() } ) {
		next if ( $_->type eq "Submit" || $_->type eq "Button" );
		tie my %obj, 'Tie::Hash::Indexed';
		if ( $_->type eq "Fieldset" ) {
			%obj =
			  ( items => \ext_items($_), title => $_->legend, autoHeight => 1 );
		} elsif ( $_->type eq "SimpleTable" ) {
			my @tr = grep { $_->tag eq "tr" } @{ $_->get_elements() };
			my @items;
			push( @items, ext_items($_) ) for (@tr);

			#die Dumper(@items);
			%obj = ( layout => "column", items => \( join( ",", @items ) ) );
		} elsif ( $_->type eq "Block" ) {
			if ( $_->tag eq "tr" ) {
				return ext_items($_);
			} elsif ( $_->tag eq "td" ) {
				%obj = (
					columnWidth => 0.5,
					layout      => 'form',
					items       => \ext_items($_)
				);
			}
		} elsif ( $_->type eq "Repeatable" ) {
			return ext_items($_);
		} elsif ( $_->type eq "Checkbox" ) {
			%obj = (
				hideLabel => 1,
				boxLabel  => $_->label,
				$_->default ? ( inputValue => $_->default ) : ()
			);
		} elsif ( $_->type eq "Blank" ) {
			%obj = ( html => $_->name );
		} elsif ( $_->type eq "Select" ) {
			my $data;
			foreach my $option ( @{ $_->_options } ) {
				push( @{$data}, [ $option->{value}, $option->{label} ] );
			}
			my $string =
			  js_dumper( { fields => [ "value", "text" ], data => $data } );
			%obj = (
				emptyText      => $_->label,
				mode           => "local",
				editable       => \0,
				displayField   => "text",
				valueField     => "value",
				hiddenName     => $_->name,
				autoWidth      => \0,
				forceSelection => \1,
				triggerAction  => "all",
				store => \( "new Ext.data.SimpleStore(" . $string . ")" )
			);
		}
		my $parent = $self->can("_get_attributes") ? $self : $self->form;
		%obj = (
			%obj,
			$_->can("label") ? ( fieldLabel => $_->label ) : (),
			$_->name         ? ( name       => $_->name )  : (),
			( $_->can("default") && $_->default )
			? ( value => $_->default )
			: (),
			$parent->_get_attributes($_)
		);
		$obj{xtype} = $map_types{ $_->type } if ( $map_types{ $_->type } );
		my $string = js_dumper( \%obj );
		utf8::decode($string);
		push( @items, \$string );
	}
	return js_dumper( \@items );
}

sub _get_attributes {
	my ( $self, $source ) = @_;
	my $obj = {};
	foreach my $attr ( "attrs_xml", "attrs" ) {
		my @keys = keys %{ $source->$attr };
		for (@keys) {
			$obj->{$_} =
			  ref( $source->$attr->{$_} ) eq "HTML::FormFu::Literal"
			  ? "" . $source->$attr->{$_}
			  : $source->$attr->{$_};
		}
	}
	return %{$obj};
}

sub ext_columns {
	my $self = shift;
	return _ext_columns($self);
}

sub _ext_columns {
	my $field = shift;
	my @return;
	my @childs =
	  grep { $_->type() !~ /submit/i && $_->can("name") }
	  @{ $field->get_all_elements() };
	return \@childs;
}

=head2 validation_response

Returns the validation response ExtJS expects as a perl Object. If the submitted values have errors
the error strings are formatted returned as well. Send this object as L<JSON> string
back to the user if you want ExtJS to mark the invalid fields or to report a success.

If the submission was successful the response contains a C<data> property which contains
all submitted values.

Examples:

  { "success" => 0,
    "errors"  => [
      { "msg" => "This field is required",
        "id"  => "field" }
    ]
  }


  { "success" => 1,
    "data"    => { field: "value" }
  }

=cut

*ext_validation = \&validation_response;

sub validation_response {
	my $form = shift;
	$form->model('HashRef')->flatten(0);
	$form->model('HashRef')->options(1);
	$form->set_options(shift);
	if ( $form->submitted_and_valid ) {
		my $return = { success => 1 };
		$form->default_values($form->params);
		$return->{data} = $form->model('HashRef')->create;
		return $return;
	} elsif ( $form->has_errors ) {
		my $return;
		$return->{success} = 0;
		for ( @{ $form->get_errors } ) {
			push(
				@{ $return->{errors} },
				{ id => $_->name, msg => $_->message }
			);
		}
		return $return;
	}
	return {};
}

sub set_options {
	my $self = shift;
	my $options = shift;
	while(my($k,$v) = each %{$options}) {
		$self->model('HashRef')->$k($v);
	}
}

sub grid_data {
    my $self   = shift;
	my $data = shift;
	$self->model('HashRef')->flatten(0);
	$self->model('HashRef')->options(1);
	my $param  = shift;
	$self->set_options(shift);
    my $rows   = $self->ext_grid_data($data);
    
    my $return = {
        results  => scalar @{$rows},
        rows     => $rows,
        metaData => {
            totalProperty => 'results',
            root          => 'rows',
            fields        => $self->_record
        }
    };
    return merge $return, $param;
}

sub form_data {
	my $self = shift;
	my $data = shift;
	$self->model('HashRef')->flatten(0);
	$self->model('HashRef')->options(0);
	$self->set_options(shift);
	return {success => \0} unless($data);
	$self->model->default_values($data);
	return {success => \1, data => $self->model('HashRef')->create};
}

sub ext_grid_data {
	my $self = shift;
	my $data = shift;
	
	my @return;
		
	
	foreach my $datum ( @{$data} ) {
		$self->model->default_values($datum);
		push(@return, $self->model('HashRef')->create);
	}
	
	return \@return;
	
}


sub column_model {
	return "new Ext.grid.ColumnModel(" . js_dumper ( shift->_column_model(@_) ) . ");";
}

sub _column_model {
    my $form = shift;
    my @add  = @_;
    my $data;
    for my $element ( @{ $form->ext_columns() } ) {
        my $class = "HTML::FormFu::ExtJS::Element::" . $element->type;
        require_class($class);
        push( @{$data}, $class->column_model($element) ) if ( $class->can("record") );
    }

    for (@add) {
        push( @{$data}, $_ );
    }
    return $data;
}

sub record {
    return "Ext.data.Record.create(" . js_dumper( shift->_record(@_) ) . ");";
}

sub _record {
    my $form = shift;
    my @add  = @_;
    my $data;
    for my $element ( @{ $form->ext_columns() } ) {
        my $class = "HTML::FormFu::ExtJS::Element::" . $element->type;
        require_class($class);
        push( @{$data}, $class->record($element) ) if ( $class->can("record") );
    }

    for (@add) {
        push( @{$data}, $_ );
    }
    return $data;
}

# sub ext_grid_data {
#     my $self = shift;
#     my $data = shift;
#     if ( blessed $data && $data->isa("DBIx::Class::ResultSet") ) {
#         my @data = $data->all;
#         $data = \@data;
#     }
#     my @return;
#     my @all_elements = @{ $self->get_all_elements() };
#     my ( %element_cache, %deflator_cache, %options_cache );
#     foreach my $datum ( @{$data} ) {
#         my $obj;
#         foreach my $column (@all_elements) {
#             next if ( $column->type =~ /submit/i );
#             my $name    = $column->name;
# 			next unless($name);
#             my $element = $element_cache{$name}
#               || $self->get_all_element($name);
#             $element_cache{$name} ||= $element;
#             next unless ($element);
#             $obj->{$name} = blessed $datum && $datum->can($name) ? $datum->$name : $datum->{$name};
# 			my $deflators = $deflator_cache{$name}
#               || $element->get_deflators;
#             $deflator_cache{$name} ||= $deflators;
# 
#             foreach my $deflator ( @{$deflators} ) {
# 
#                 $obj->{$name} = $deflator->deflator( $obj->{$name} );
#             }
# 
# 			if(blessed $datum && $datum->can($name) && blessed $datum->$name && $datum->$name->can('count')) {
# 				$obj->{$name} = $datum->$name->count;
# 				next;
# 			}
# 
#             my $can_options = $options_cache{$name}
#               || $element->can("_options");
#             $options_cache{$name} ||= $element->can("_options");
#             if ($can_options) {
#                 my @options = @{ $element->_options };
#                 my @option = grep { $_->{value} eq $obj->{$name} } @options;
# 				unless(@option) {
# 					@options = map { @{$_->{group} || []} } @options;
# 					@option = grep { $_->{value} eq $obj->{$name} } @options ;
# 				}
#                 $obj->{$name} = join(", ", map { $_->{label} } @option);
#             }
# 
# 			if($column->type eq "Checkbox") {
# 				$obj->{$name} = \1 if($obj->{$name});
# 			}
#         }
#         push( @return, $obj );
#     }
#     return \@return;
# }

1;

=head1 EXAMPLES

These examples imply that you use L<Catalyst> as web framework and L<Template Toolkit|Template> as the templating engine.

=head2 simple form submission and validation

Create a config file for the form (form.yml):

  ---
  action: /contacts/create
  
  elements:

  - type: Text
    name: name
    label: Name
    constraints:
      - Required

  - type: Text
    name: address
    label: Address
    constraints:
      - Required

  - type: Button
    name: submit
    default: Submit
    attrs:
      handler: submitForm

In the last line there is a handler specified which is called when you press the submit button.
This handler needs to be implemented using JavaScript.

Usually you have a JavaScript file which contains all the code you need for your page. To render
the form you need to put the form definition in this file. Pass the form object to the stash
so that you can access it from the template.

  sub js : Local {
      my ($self, $c) = @_;
      my $form = new HTML::FormFu::ExtJS;
      $form->load_config_file('root/forms/form.yml');
      $c->stash->{form} = $form;
      $c->stash->{template} = 'javascript.tt2';
  }

javascript.tt2:

  var submitForm = function() {
    form.getForm().submit({
	  success: function(rst, req) {
        // submission was successful and valid
    }
  }
  var form = [% form.render %];
  

=head1 CAVEATS

=head2 L<Multi|HTML::FormFu::ExtJS::Element::Multi>

The Multi element is rendered using the ExtJS column layout. It seems like this 
layout doesn't allow a label next to it. This module adds a new column as first element
which has a field label specified and a hidden text box. I couldn't find a setup
where this hack failed. But there might be some cases where it does.

=head2 L<Select|HTML::FormFu::ExtJS::Element::Select>

Optgroups are partially supported. They render as a normal element of the select box and 
are therefore selectable.

=head2 L<File|HTML::FormFu::ExtJS::Element::File>

With ExtJS 2.2 comes an option of the form panel which allows file uploads. Make sure you set
C<fileUpload> at the form panel to C<true>.

See L<http://extjs.com/deploy/dev/docs/?class=Ext.form.BasicForm> / fileUpload.

=head2 L<Buttons|HTML::FormFu::ExtJS::Element::Button>

Buttons cannot be placed in-line as ExtJS expects them to be in a different attribute. A
button next to a text box is therefore (not yet) possible. Buttons are always rendered at
the bottom of a form panel.

=head2 Comments

There is no support for comments yet. A work-around is to create a 
L<Multi|HTML::FormFu::ExtJS::Element::Multi> element, add the
element you want to comment in the first column and the comment as a 
L<Src|HTML::FormFu::ExtJS::Element::Src> element in the
second column.

=head2 Block

Each element in a C<Block> element is rendered normally. The C<tag> config option has no
influence. If the C<Block> element contains a C<content> it is rendered like 
a L<Src|HTML::FormFu::ExtJS::Element::Src> element.

=head1 SUBVERSION REPOSITORY

Latest development version is avaiable from L<http://html-formfu.googlecode.com/svn/trunk/HTML-FormFu-ExtJS/>.

=head1 TODO

=over

=item Write a Catalyst example application with validation, data grids and DBIC (sqlite).


=back

=head1 SEE ALSO

L<HTML::FormFu>, L<JavaScript::Dumper>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
