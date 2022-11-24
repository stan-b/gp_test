#!usr/bin/perl

use strict;
use warnings;
use DBI;
 use Data::Dumper;
 
my $results = '';
# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=gazprom;host=localhost",
                       "stan", "aqua32",
                       {'RaiseError' => 1});
                       
my $search_query = 'ceftpqlvefv@mail.ru';
my $limit = 100;
#if (length ($ENV{'QUERY_STRING'}) > 0){
   # $search_query = $ENV{'QUERY_STRING'};
    my $events = $dbh->selectall_arrayref(
    "(SELECT SQL_CALC_FOUND_ROWS message.created, message.int_id FROM message WHERE message.int_id IN (SELECT log.int_id FROM log WHERE log.address = ?)) UNION ALL (SELECT created, int_id FROM log WHERE address = ?) LIMIT ?",  { Slice => {} }, $search_query, $search_query, $limit

);

my $row_count = $dbh->selectrow_array("SELECT FOUND_ROWS()");

foreach my $event ( @$events ) {
    $results.= qq[Created: $event->{created} | Internal id:  $event->{int_id}<br>];
}
if ($row_count > 100) {
    $results .= qq[Всего результатов: $row_count, из них выведено $limit];
}
#};



my $html = qq[
<!DOCTYPE html>
<html lang="en">

<head>
  <meta name="description" content="Webpage description goes here" />
  <meta charset="utf-8">
  <title>Change_me</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="author" content="">
</head>

<body>
  
<div class="container">
  $results
</div>

<script>
</script>

</body>
</html>];

print $html;