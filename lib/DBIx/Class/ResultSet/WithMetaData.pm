package DBIx::Class::ResultSet::WithMetaData;

use strict;
use warnings;

use Data::Alias;
use Moose;
use Method::Signatures::Simple;
extends 'DBIx::Class::ResultSet';

has '_row_info' => (
  is => 'rw',
  isa => 'HashRef'
);

has 'was_row' => (
  is => 'rw',
  isa => 'Int'
);

has 'id_cols' => (
  is => 'rw',
  isa => 'ArrayRef',
);

=head1 VERSION

Version 0.999003

=cut

our $VERSION = '0.999003';

=head1 NAME

DBIx::Class::ResultSet::WithMetaData

=head1 SYNOPSIS

  package MyApp::Schema::ResultSet::ObjectType;

  use Moose;
  use MooseX::Method::Signatures;
  extends 'DBIx::Class::ResultSet::WithMetaData;

  method with_substr () {
    foreach my $row ($self->all) {
      my $substr = substr($row->name, 0, 3);
      $self->add_row_info(row => $row, info => { substr => $substr });
    }
    return $self;
  }

  ...


  # then somewhere else

  my $object_type_arrayref = $object_type_rs->with_substr->display();

  # [{
  #    'artistid' => '1',
  #    'name' => 'Caterwauler McCrae',
  #    'substr' => 'Cat'
  #  },
  #  {
  #    'artistid' => '2',
  #    'name' => 'Random Boy Band',
  #    'substr' => 'Ran'
  #  },
  #  {
  #    'artistid' => '3',
  #    'name' => 'We Are Goth',
  #    'substr' => 'We '
  #  }]

=head1 DESCRIPTION

Attach metadata to rows by chaining ResultSet methods together. When the ResultSet is
flattened to an ArrayRef the attached metadata is merged with the row hashes to give
a combined 'hash-plus-other-stuff' representation.

=head1 METHODS

=cut

sub new {
  my $self = shift;

  my $new = $self->next::method(@_);
  foreach my $key (qw/_row_info was_row id_cols/) {
    alias $new->{$key} = $new->{attrs}{$key};
  }

  unless ($new->_row_info) {
    $new->_row_info({});
  }

  unless ($new->id_cols && scalar(@{$new->id_cols})) {
    $new->id_cols([sort $new->result_source->primary_columns]);
  }

  return $new;
}

=head2 display

=over 4

=item Arguments: none

=item Return Value: ArrayRef

=back

 $arrayref_of_row_hashrefs = $rs->display();

This method uses L<DBIx::Class::ResultClass::HashRefInflator> to convert all
rows in the ResultSet to HashRefs. These are then merged with any metadata
that had been attached to the rows using L</add_row_info>.

=cut

method display () {
  my $rs = $self->search({});
  $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
  my @rows;
  foreach my $row ($rs->all) {
    if (my $info = $self->row_info_for(id => $self->_mk_id(row => $row))) {
      $row = { %{$row}, %{$info} };
    }
    push(@rows, $row);
  }

  return ($self->was_row) ? $rows[0] : \@rows;
}

=head2 add_row_info

=over 4

=item Arguments: row => DBIx::Class::Row object, info => HashRef to attach to the row

=item Return Value: ResultSet

=back

 $rs = $rs->add_row_info(row => $row, info => { dates => [qw/mon weds fri/] } );

This method allows you to attach a HashRef of metadata to a row which will be merged
with that row when the ResultSet is flattened to a datastructure with L</display>.

=cut

method add_row_info (%opts) {
  my ($row, $id, $info) = map { $opts{$_} } qw/row id info/;
  if ($row) {
    $id = $self->_mk_id(row => { $row->get_columns });
  }

  unless ($row || $self->find($id)) {
    die 'invalid id passed to add_row_info';
  }

  if (my $existing = $self->_row_info->{$id}) {
    $info = { %{$existing}, %{$info} };
  }

  $self->_row_info->{$id} = $info;  
}

method row_info_for (%opts) {
  my $id = $opts{id};
  return $self->_row_info->{$id};
}

method _mk_id (%opts) {
  my $row = $opts{row};
  return join('-', map { $row->{$_} } @{$self->id_cols});
}

=head1 AUTHOR

  Luke Saunders <luke.saunders@gmail.com>

=head1 THANKS

As usual, thanks to Matt S Trout for the sanity check.

=head1 LICENSE

  This library is free software under the same license as perl itself

=cut

1;
