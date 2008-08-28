use Test::More;

use HTML::FormFu::ExtJS::Grid;
use strict;
use warnings;

use lib qw(t/lib);

use DBICTest;
use Data::Dumper;

my $schema = DBICTest->init_schema();

BEGIN {
	eval "use DBIx::Class";
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBIx::Class and DBD::SQLite for testing' )
        : ( tests => 4 );
}

my $rs = $schema->resultset("Artist")->search(undef, {order_by => 'name asc'});

my $form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file('t/09-grid_data.yml');
my $data = $form->grid_data($rs);
my $expected = {
          'metaData' => {'fields' => [{'name' => 'artistid','type' => 'string'
                                    },{'name' => 'name','type' => 'string'}],'totalProperty' => 'results',
                        'root' => 'rows'},
          'rows' => [{'artistid' => '1','name' => 'Caterwauler McCrae'
                    },{'artistid' => '2','name' => 'Random Boy Band'
                    },{'artistid' => '3','name' => 'We Are Goth'}],'results' => 3};
is_deeply($data, $expected);
my @rows = $rs->all;
$data = $form->grid_data(\@rows);
is_deeply($data, $expected);
$data = $form->grid_data([{'artistid' => '1','name' => 'Caterwauler McCrae'
            },{'artistid' => '2','name' => 'Random Boy Band'
            },{'artistid' => '3','name' => 'We Are Goth'}]);
is_deeply($data, $expected);

$data = $form->grid_data(\@rows, {results => 99});
$expected->{results} = 99;
is_deeply($data, $expected);
