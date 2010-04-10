package HTML::FormFu::Element::ExtJS::TabPanel;
# ABSTRACT: FormFu class for ExtJS tab panels

use strict;
use base 'HTML::FormFu::Element::ExtJS::Panel';

sub new {
    my $self = shift->next::method(@_);
    $self->xtype( 'tabpanel' );
    return $self;
}

1;

__END__


=head1 DESCRIPTION

FormFu class for ExtJS tab panels.

=head1 METHODS

=head2 xtype

Defaults to 'tabpanel'

=head2 Attributes

The ExtJS TabPanel supports the following attributes in addition to Panel attributes.
Number, Float, Boolean are type checked.
In YAML configration use 0 for false and 1 for true.

=over

=item *
activeTab:String/Number

=item *
animScroll:Boolean

=item *
autoTabSelector:String

=item *
autoTabs:Boolean

=item *
baseCls:String

=item *
enableTabScroll:Boolean

=item *
itemTpl:Template/XTemplate

=item *
layoutConfig:Object

=item *
layoutOnTabChange:Boolean

=item *
minTabWidth:Number

=item *
plain:Boolean

=item *
resizeTabs:Boolean

=item *
scrollDuration:Float

=item *
scrollIncrement:Number

=item *
scrollRepeatInterval:Number

=item *
tabCls:String

=item *
tabMargin:Number

=item *
tabPosition:String

=item *
tabTip:String

=item *
tabWidth:Number

=item *
wheelIncrement:Number

=back

See Class Ext.TabPanel http://www.extjs.com/docs/?class=Ext.TabPanel for further details

=head1 EXAMPLE

The following YAML configuration exmaple sets optional attributes including activeTab. 'activeTab' defaults to 0
which is the first tab, to have no tab selected set activeTab to negative.

	---
	attrs:
	  standardSubmit: 1
	elements:
	  - type: ExtJS::TabPanel
	    attrs:
	       enableTabScroll: 1
	       animScroll: 1
	       border: 1
	       minTabWidth: 150
	       resizeTabs: true
	       height: 300
	       width: 250
	       activeTab: 1
	       resizeTabs: 1
	       tabWidth: 200
	    elements:
	      - type: ExtJS::Panel
	        label: Tab1
	        attrs:
	          layout: form
	        elements:
	          - type: Text
	            name: tab1input1
	            label: Tab1-Input1
	          - type: Text
	            name: tab1input2
	            label: Tab1-Input2
	      - type: ExtJS::Panel
	        label: Tab2
	        attrs:
	          layout: form
	        elements:
	          - type: Text
	            name: tab2input1
	            label: Tab2-Input1
	          - type: Text
	            name: tab2input2
	            label: Tab2-Input2


=head1 SEE ALSO

The ExtJS specific stuff is in L<HTML::FormFu::ExtJS::Element::ExtJS::TabPanel>

=head1 AUTHOR

Damon Atkins

Based on HTML::FormFu::Element::ExtJS::Panel

