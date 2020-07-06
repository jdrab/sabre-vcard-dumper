# Sabredav vcard exporter
---------------------------------------------------------

Exports vcard data to a $UUID.vcf in directory data/user_login/addressbook_uri/UUID.vcf, if files.one_vcard_per_contact is set to 1.
Also if files.one_merged_vcard_per_addressbook is set to 1 a merged $addressbook.vcf will be created per addressbook.

**Note**: does not check the vcard validity


**config.yml** 

~~~yaml
---
db:
  # perl DBI dns line, paste there whatever your db driver needs
  dsn: DBI:mysql:database=sabredav;host=localhost
  user: dbusername
  password: dbpassword
  # addressbooks table - default addressbooks
  tbl_addressbooks: addressbooks
  # cards table - defautl cards
  tbl_cards: cards 
  # once again, parameters for DBI driver
  options:
    RaiseError: 1
    AutoCommit: 0

# 0 - no/false, 1 - yes/true
files:
  # if for some reason you don't want to create data_dir
  create_folders: 1
  # by default script removes data_dir and recreates it if necessary
  delete_data_dir_before_create: 1
  # export every contact to separate vcard - default - 1
  one_vcard_per_contact: 1
  # merge addressbook vcards to one $addressbook.vcf - default -1
  one_merged_vcard_per_addressbook: 1
  # data_dir is relative to script location; should not include
  # ending slash
  data_dir: data
  # params for File::Path used by make_path and remove_tree subroutines
  path_options:
    # by default I'd like to know what is happening
    verbose: 1

~~~
