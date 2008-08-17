package HTML::FormFu::ExtJS;
use base HTML::FormFu;
use strict;
use warnings;
use Scalar::Util qw/ weaken /;
use Carp qw/ croak carp /;
use utf8;
use JavaScript::Dumper;
use Tie::Hash::Indexed;
use Data::Dumper;
our $VERSION = '0.00001';
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

Check out the examples in C<examples/html>.

=head1 METHODS

A HTML::FormFu::ExtJS object inherits all methods of a L<HTML::FormFu> object. There are some additional methods avaiable:

=head2 render

Returns a full ExtJS form panel. Usually you'll use this like this (L<TT|Template> example):

  var form = [% form.render %];

C<form> is now a JavaScript object of type C<Ext.FormPanel>. You might want to put some handlers on the button so they will
trigger a function when clicked.

  Ext.getCmp("id-of-your-button").setHandler(function() { alert('clicked') } );

=cut

sub render {
	my $self = shift;
	return "new Ext.FormPanel(".js_dumper($self->_render(@_)).");";
}

sub _render {
	my $self = shift;
	my %param = @_;
	return {items => $self->_render_items, buttons => $self->_render_buttons, %param};
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
	my $self = shift;
	return js_dumper( $self->_render_items );
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
			$obj->{$_} = ref( $source->$attr->{$_} ) eq "HTML::FormFu::Literal"
			  ?
			  "" . $source->$attr->{$_}
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

Returns the validation response ExtJS expects. If the submitted values have errors
the error strings are formatted as a JSON string and returned. Send this string
back to the user if you want ExtJS to mark the invalid fields or to report a success.

If the submission was successful the response contains a C<data> object which contains
all submitted values.

Examples:

  { "success" : 0,
    "errors"  : [
      { "msg" : "This field is required",
        "id"  : "field" }
    ]
  }


  { "success" : 1,
    "data"    : { field: "value" }
  }

=head2 _validation_response

Acts like L</validation_response> but returns a perl object instead.

=cut
*ext_validation = \&_validation_response;

sub validation_response {
	return js_dumper( shift->_validation_response );
}

sub _validation_response {
	my $form = shift;
	if ( $form->submitted_and_valid ) {
		my $return = { success => 1 };
		my @columns = @{ $form->ext_columns };
		for (@columns) {
			next unless ( $_->{name} );
			$return->{data}->{ $_->{name} } = $form->param( $_->{name} );
		}
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
1;

=head1 KNOWN PROBLEMS

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

=head2 L<Buttons|HTML::FormFu::ExtJS::Element::Button>

Buttons cannot be placed in-line as ExtJS expects them to be in a different attribute. A
button next to a text box is therefore (not yet) possible. Buttons are always rendered at
the bottom of a form panel.

See L<http://extjs.com/deploy/dev/docs/?class=Ext.form.BasicForm> / fileUpload.

=head1 SEE ALSO

L<HTML::FormFu>, L<JavaScript::Dumper>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
