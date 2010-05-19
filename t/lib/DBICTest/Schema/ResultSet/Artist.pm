package DBICTest::Schema::ResultSet::Artist;

use Moose;
use Method::Signatures::Simple;
extends 'DBICTest::Schema::ResultSet';

method with_substr_multi () {
  $self->_with_meta_hash( 
    sub {
      my $row = shift;
      my $substr = substr($row->{name}, 0, 3);
      my $substr2 = substr($row->{name}, 0, 4);
      $row->{substr} = $substr;
      $row->{substr2} = $substr2;
      return $row;
    }
  );
  return $self;
}

method with_substr_key () {
  $self->_with_meta_key( 
    substr => sub {
      return substr(shift->{name}, 0, 3);
    }
  );
  return $self;
}

method with_substr_old () {
  foreach my $row ($self->all) {
    my $substr = substr($row->name, 0, 3);
    $self->add_row_info(row => $row, info => { substr => $substr });
  }
  return $self;
}

1;
