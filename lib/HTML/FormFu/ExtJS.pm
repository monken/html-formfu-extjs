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

sub _render_items {
	my $self   = shift;
	my $from   = shift || $self;
	my $output = [];
	foreach my $element ( @{ $from->get_elements() } ) {
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
		}
		elsif ( $_->type eq "SimpleTable" ) {
			my @tr = grep { $_->tag eq "tr" } @{ $_->get_elements() };
			my @items;
			push( @items, ext_items($_) ) for (@tr);

			#die Dumper(@items);
			%obj = ( layout => "column", items => \( join( ",", @items ) ) );
		}
		elsif ( $_->type eq "Block" ) {
			if ( $_->tag eq "tr" ) {
				return ext_items($_);
			}
			elsif ( $_->tag eq "td" ) {
				%obj = (
					columnWidth => 0.5,
					layout      => 'form',
					items       => \ext_items($_)
				);
			}
		}
		elsif ( $_->type eq "Repeatable" ) {

			return ext_items($_);

		}
		elsif ( $_->type eq "Checkbox" ) {
			%obj = (
				hideLabel => 1,
				boxLabel  => $_->label,
				$_->default ? ( inputValue => $_->default ) : ()
			);
		}
		elsif ( $_->type eq "Blank" ) {
			%obj = ( html => $_->name );
		}
		elsif ( $_->type eq "Select" ) {
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
			$obj->{$_} = "".$source->$attr->{$_};
		}
	}
	return %{$obj};
}

sub ext_buttons {
	my $self = shift;
	my @buttons;
	for ( @{ $self->get_elements() } ) {
		next unless ( $_->type eq "Submit" || $_->type eq "Button" );
		push( @buttons,
			sprintf( "{text: '%s', handler: submitForm}", $_->value ) );
	}
	return "[" . join( ",\n", @buttons ) . "]";
}

sub ext_grid_data {
	my $self = shift;
	my $data = shift;
	use DBIx::Class::ResultClass::HashRefInflator;
	if ( ref $data eq "DBIx::Class::ResultSet" ) {

		#$data->result_class('DBIx::Class::ResultClass::HashRefInflator');
		my @data = $data->all;
		$data = \@data;
	}
	my @return;
	my @all_elements = @{ $self->get_all_elements() };
	my ( %element_cache, %deflator_cache, %options_cache );
	foreach my $datum ( @{$data} ) {
		my $obj;
		foreach my $column (@all_elements) {
			next if ( $column->type =~ /submit/i );
			my $name = $column->name;
			my $element = $element_cache{$name} || $self->get_element($name);
			$element_cache{$name} ||= $element;
			next unless ($element);
			$obj->{$name} = $datum->$name;
			my $deflators = $deflator_cache{$name} || $element->get_deflators;
			$deflator_cache{$name} ||= $deflators;

			foreach my $deflator ( @{$deflators} ) {

				$obj->{$name} = $deflator->deflator( $obj->{$name} );
			}
			my $can_options = $options_cache{$name}
			  || $element->can("_options");
			$options_cache{$name} ||= $element->can("_options");
			if ($can_options) {
				my @options = @{ $element->_options };
				my @option = grep { $_->{value} eq $obj->{$name} } @options;
				$obj->{$name} = $option[0]->{label};
			}
		}
		push( @return, $obj );
	}
	return \@return;
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

sub ext_data_reader {
	my $form = shift;
	my @add  = @_;
	my $data;
	for ( @{ $form->ext_columns() } ) {
		push( @{$data}, { name => $_->name } )
		  if ( $_->can("name") && $_->name );
	}
	for (@add) {
		push( @{$data}, { name => $_ } );
	}
	return js_dumper($data);
}

sub ext_validation {
	my $form = shift;
	if ( $form->submitted_and_valid ) {
		my $return = { success => 1 };
		my @columns = @{ $form->ext_columns };
		for (@columns) {
			next unless ( $_->{name} );
			$return->{data}->{ $_->{name} } = $form->param( $_->{name} );
		}
		return $return;
	}
	elsif ( $form->has_errors ) {
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

=head1 Avaiable Elements

=over 

=item L<Blank|HTML::FormFu::ExtJS::Element::Blank>

=item L<Hidden|HTML::FormFu::ExtJS::Element::Hidden>

=item L<Hr|HTML::FormFu::ExtJS::Element::Hr>

=item L<Hr|HTML::FormFu::ExtJS::Element::Select>

=item L<Text|HTML::FormFu::ExtJS::Element::Text>

