package HTML::FormFu::ExtJS::Grid;

use base "HTML::FormFu::ExtJS";

use JavaScript::Dumper;
use Hash::Merge::Simple qw(merge);
use Scalar::Util 'blessed';

use utf8;

use strict;
use warnings;

use HTML::FormFu::Util qw/require_class/;

=head1 NAME

HTML::FormFu::ExtJS::Grid

=head1 DESCRIPTION

If you want to present data which has been submitted by a form in a ExtJS grid chose this module.
Simply use it instead of L<HTML::FormFu> or L<HTML::FormFu::ExtJS>.

=head1 METHODS

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

sub grid_data {
    my $self   = shift;
    my $rows   = $self->ext_grid_data(shift);
    my $param  = shift;
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

sub ext_grid_data {
    my $self = shift;
    my $data = shift;
    if ( blessed $data && $data->isa("DBIx::Class::ResultSet") ) {
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
            my $name    = $column->name;
            my $element = $element_cache{$name}
              || $self->get_element($name);
            $element_cache{$name} ||= $element;
            next unless ($element);
            $obj->{$name} = blessed $datum ? $datum->$name : $datum->{$name};
            my $deflators = $deflator_cache{$name}
              || $element->get_deflators;
            $deflator_cache{$name} ||= $deflators;

            foreach my $deflator ( @{$deflators} ) {

                $obj->{$name} = $deflator->deflator( $obj->{$name} );
            }

			if(blessed $datum && blessed $datum->$name && $datum->$name->can('count')) {
				$obj->{$name} = $datum->$name->count;
				next;
			}

            my $can_options = $options_cache{$name}
              || $element->can("_options");
            $options_cache{$name} ||= $element->can("_options");
            if ($can_options) {
                my @options = @{ $element->_options };
                my @option = grep { $_->{value} eq $obj->{$name} } @options;
				unless(@option) {
					@options = map { @{$_->{group}} } @options;
					@option = grep { $_->{value} eq $obj->{$name} } @options ;
				}
                $obj->{$name} = join(", ", map { $_->{label} } @option);
            }
        }
        push( @return, $obj );
    }
    return \@return;
}

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

1;

=head1 SEE ALSO

L<HTML::FormFu::ExtJS>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
