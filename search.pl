#!usr/bin/perl

use strict;
use warnings;
use DBI;
use Data::Dumper;

my $html_data = '';

# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=gazprom;host=localhost", "stan", "aqua32", { 'RaiseError' => 1 });

my $limit = 100;
my $counter = 0;
#$ENV{'QUERY_STRING'} = 'query=ceftpqlvefv@mail.ru';
if (length($ENV{'QUERY_STRING'}) > 0) {
  my ($search_query) = $ENV{'QUERY_STRING'} =~ /query=(.*)$/;

  my $events = $dbh->selectall_arrayref(
"(SELECT SQL_CALC_FOUND_ROWS message.created, message.int_id FROM message WHERE message.int_id IN (SELECT log.int_id FROM log WHERE log.address = ?)) UNION ALL (SELECT created, int_id FROM log WHERE address = ?) LIMIT ?",
    { Slice => {} }, $search_query, $search_query, $limit
  );

  my $row_count = $dbh->selectrow_array("SELECT FOUND_ROWS()");

  foreach my $event (@$events) {
    $counter++;
    $html_data .= qq[$counter) Created: $event->{created} | Internal id:  $event->{int_id}<br>];
  }
  if ($row_count > 100) {
    $html_data .= qq[Всего результатов: $row_count, из них выведено $limit];
  }

} else {
  $html_data .= qq[
  <form action="" method="get">
  <label for="site-search">Введите email:</label>
  <input type="search" id="site-search" name="query">
  <button>Search</button>
  </form>];
}
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
  $html_data
</div>

<script>
</script>

</body>
</html>];

print $html;
