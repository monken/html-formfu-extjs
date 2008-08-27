package HTML::FormFu::ExtJS::Element::Date;

use base "HTML::FormFu::ExtJS::Element::_Field";

use strict;
use warnings;
use utf8;

sub render {
	my $class = shift;
	my $self = shift;
	$self->_date_defaults;
	$self->default(sprintf("%04s-%02s-%02s", $self->year->{default},$self->month->{default},$self->day->{default}))
	if($self->year->{default} && $self->month->{default} && $self->day->{default});
	
	my $super = $class->SUPER::render($self);
	return { %{$super}, xtype => "datefield" };
	
	
}

sub record {
	my $class = shift;
	my $self = shift;
	my $super = $class->SUPER::record($self);
	return {%{$super}, type => "date", dateFormat => 'Y-m-d'}
}

1;

=head1 NAME

HTML::FormFu::ExtJS::Element::Date - Date element

=head1 DESCRIPTION

Du not put inside a Multi block as it is itself a multi block.

=head1 SEE ALSO

L<HTML::FormFu::Element::Date>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut