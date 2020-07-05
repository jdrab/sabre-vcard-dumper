#!/usr/bin/env perl
use warnings;
use strict;

our $VERSION = 0.1.1;

use Path::Tiny;
use YAML::Syck;
use DBI;
use File::Path qw(make_path remove_tree);

# parse config
my $config = LoadFile('config.yml');

# Connect to the database.
my $dbh = DBI->connect( $config->{db}{dsn},      $config->{db}{user},
                        $config->{db}{password}, $config->{db}{options} );

# describe addressbooks;
# +--------------+------------------+------+-----+---------+----------------+
# | Field        | Type             | Null | Key | Default | Extra          |
# +--------------+------------------+------+-----+---------+----------------+
# | id           | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
# | principaluri | varbinary(255)   | YES  | MUL | NULL    |                |
# | displayname  | varchar(255)     | YES  |     | NULL    |                |
# | uri          | varbinary(200)   | YES  |     | NULL    |                |
# | description  | text             | YES  |     | NULL    |                |
# | synctoken    | int(11) unsigned | NO   |     | 1       |                |
# +--------------+------------------+------+-----+---------+----------------+

# select * from addressbooks where id = 1;
# +----+-----------------+--------------------+---------+-------------+-----------+
# | id | principaluri    | displayname        | uri     | description | synctoken |
# +----+-----------------+--------------------+---------+-------------+-----------+
# |  1 | principals/usr1 | ABCDEF Addressbook | default |             |        17 |
# +----+-----------------+--------------------+---------+-------------+-----------+

#select principaluri form addressbooks do pola principaluris
my $a_tbl = $dbh->quote_identifier( $config->{db}{tbl_addressbooks} );
my $stmt  = $dbh->prepare("SELECT id,principaluri,uri,displayname FROM $a_tbl");
$stmt->execute();

my %data;

# go through all addressbooks
while ( my $ref = $stmt->fetchrow_hashref ) {

    # get users login from princpialuri
    my $login = ( split /\//msx, $ref->{principaluri} )[1];

    # and assign some data to users hash
    $data{$login}{ $ref->{uri} } = { id           => $ref->{id},
                                     displayname  => $ref->{displayname},
                                     principaluri => $ref->{principaluri},
                                     cards        => []
    };

    # get all users vcards by his addressbookid
    my $c_tbl = $dbh->quote_identifier( $config->{db}{tbl_cards} );
    my $c_stmt = $dbh->prepare(
                     "SELECT carddata,uri FROM $c_tbl where addressbookid = ?");
    $c_stmt->execute( $ref->{id} );

    # go through all his cards and push them
    while ( my $cref = $c_stmt->fetchrow_hashref ) {

        push @{ $data{$login}{ $ref->{uri} }{cards} },
          { carddata => $cref->{carddata}, uri => $cref->{uri} };

    }
}

if ( $config->{files}{delete_data_dir_before_create} == 1 ) {
    my $removed = remove_tree( $config->{files}{data_dir},
                               $config->{files}{path_options} );
}

#foreach user $data{login}
foreach my $user ( keys %data ) {

    # unless ( $user eq 'somi' ) { next; }
    foreach my $addressbook ( keys %{ $data{$user} } ) {

        #ak ma aspon jeden kontakt, tzn size v cards poli > 0
        if ( scalar( @{ $data{$user}{$addressbook}{cards} } ) == 0 ) {
            next;
        }

        my $addressbook_path = "$config->{files}{data_dir}/$user/$addressbook";

        if ( $config->{files}{create_folders} == 1 ) {
            my @p_folder
              = make_path( $addressbook_path, $config->{files}{path_options} );
        }

        foreach my $vcard ( @{ $data{$user}{$addressbook}{cards} } ) {

            if ( $config->{files}{path_options}{verbose} == 1 ) {
                print "writing $addressbook_path/$vcard->{uri}\n";
                print
                  "\tappending content of $addressbook_path/$vcard->{uri} to _full.vcf\n";
            }
            if ( $config->{files}{one_vcard_per_contact} == 1 ) {
                path( $addressbook_path . q{/} . $vcard->{uri} )
                  ->spew( $vcard->{carddata} );
            }

            if ( $config->{files}{one_merged_vcard_per_addressbook} == 1 ) {
                path( $addressbook_path . q{/} . $addressbook . '.vcf' )
                  ->append( $vcard->{carddata} . "\n" );
            }

        }
    }

}

$dbh->disconnect;

1;
