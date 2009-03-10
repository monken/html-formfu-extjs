use Test::More tests => 3;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file('t/column_model/01-basic.yml');
my $data = $form->grid_data([{name => 'foo', sex => 0, cds => 3}, {name => 'bar', sex => 1, cds => 4}]);

print $form->column_model.$/;

print $form->record.$/;