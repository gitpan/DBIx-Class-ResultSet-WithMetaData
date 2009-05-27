#!perl

use Test::More tests => 3;
use lib qw(t/lib);
use DBICTest;
use Data::Dumper;

# set up and populate schema
ok(my $schema = DBICTest->init_schema(), 'got schema');

{
	my $artist_rs = $schema->resultset('Artist')->search({}, { order_by => 'artistid' })->display();
	is_deeply($artist_rs, [
		{
			'artistid' => '1',
			'name' => 'Caterwauler McCrae'
		},
		{
			'artistid' => '2',
			'name' => 'Random Boy Band'
		},
		{
			'artistid' => '3',
			'name' => 'We Are Goth'
		}
	], 'ordered display returned as expected');
}

{
	my $artists = $schema->resultset('Artist')->search({}, { order_by => 'artistid' })->with_substr->display();
	is_deeply($artists, [
		{
			'artistid' => '1',
			'name' => 'Caterwauler McCrae',
			'substr' => 'Cat'
		},
		{
			'artistid' => '2',
			'name' => 'Random Boy Band',
			'substr' => 'Ran'
		},
		{
			'artistid' => '3',
			'name' => 'We Are Goth',
			'substr' => 'We '
		}
	], 'display with substring okay');
}



