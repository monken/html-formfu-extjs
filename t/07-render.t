use Test::More tests => 2;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file("t/01-text.yml");

is_deeply( $form->_render, {
          'buttons' => [],
          'items' => [
                     {
                       'hideLabel' => \1,
                       'name' => 'test',
                       'fieldLabel' => undef,
                       'id' => 'test_id',
                       'xtype' => 'textfield',
                       'labelWidth' => '10'
                     },
                     {
                       'hideLabel' => \0,
                       'name' => 'test2',
                       'fieldLabel' => 'Test',
                       'id' => undef,
                       'xtype' => 'textfield'
                     }
                   ]
        });
        
ok($form->render);