use Test::More tests => 2;

use HTML::FormFu::ExtJS::Grid;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file("t/01-text.yml");
is_deeply( $form->_record , [{name => "test", type => "string"}, {name => "test2", type => "string"}]);

ok($form->render_items);
