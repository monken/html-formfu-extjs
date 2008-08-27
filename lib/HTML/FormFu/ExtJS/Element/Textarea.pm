package HTML::FormFu::ExtJS::Element::Textarea;

use base "HTML::FormFu::ExtJS::Element::_Field";

use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::render($self);
	if($self->{attributes}->{wysiwyg}) {
	return { %{$super}, xtype => "htmleditor" };
	}
	return { %{$super}, xtype => "textarea" };
	
	
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Textarea - Textarea element

=head1 DESCRIPTION

You can either use the standard html textarea element or use the ExtJS WYSIWYG editor:

  - type: Textarea 

  - type: Textarea
    attrs_xml:
      wysiwyg: 1



=head1 SEE ALSO

L<HTML::FormFu::Element::Textarea>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut