#!usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use DBI;

# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=gazprom;host=localhost", "stan", "aqua32", { 'RaiseError' => 1 });

my $filename = 'out';
my $counter = 0;

# названия индексов для понятности

my $message_date = 0;
my $message_time = 1;
my $message_internal_id = 2;
my $message_flag = 3;
my $message_email_address = 4;
my $message_other = 5;

my $handle;
unless (open $handle, "<:encoding(utf8)", $filename) {
  print STDERR "Ошибка открытия файла '$filename': $!\n";

  return undef;
}
chomp(my @lines = <$handle>);
unless (close $handle) {
  print STDERR "Невозможно закрыть файл '$filename': $!\n";
}

$dbh->do("START TRANSACTION");
foreach (@lines) {
  my @message_data = split(' ', $_);
  my $log_str = join(' ', @message_data[ 2 .. $#message_data ]);
  my $created = join(' ', @message_data[ 0 .. 1 ]);
  my ($id) = $_ =~ /id=(.*)$/;
  my $int_id = $message_data[$message_internal_id];

  if ($message_data[$message_flag] eq '<=') {
    if (defined $id) {
      $counter++ if $dbh->do("INSERT INTO message VALUES (?, ?, ?, ?, ?)", undef, $created, $id, $int_id, $log_str, 1);
    } else {
      print "No id for $log_str\n";
    }

  } else {
    my $recipient_email = $message_data[$message_email_address];

    #print "$log_str\n";
    $counter++ if $dbh->do("INSERT INTO log VALUES (?, ?, ?, ?)", undef, $created, $int_id, $log_str, $recipient_email);
  }

}

$dbh->do("COMMIT");

print "Вставлено $counter записей.\n";
