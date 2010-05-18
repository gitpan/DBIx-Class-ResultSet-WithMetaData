package DBICTest::Schema::ResultSet::Artist;

use Moose;
use Method::Signatures::Simple;
extends 'DBICTest::Schema::ResultSet';

method with_substr () {
	foreach my $row ($self->all) {
		my $substr = substr($row->name, 0, 3);
		$self->add_row_info(row => $row, info => { substr => $substr });
	}
	return $self;
}

1;
