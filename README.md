# Simple script for dumping vcards from sabredav database
---------------------------------------------------------

Saves vcard data to UUID.vcf in directory data/_user_login_/_addressbook_uri/UUID.vcf.

For evey addressbook it creates a _full.vcf is created, containing all contacts in _addressbook_uri directory.

Also creates _full.vcf in "data_dir" directory.

**Note**: does not check the vcard validity


**config.yml** - description, pretty self-explanatory

~~~yaml
---
db:
  # perl DBI dns line, paste there whatever your db driver needs
  dsn: DBI:mysql:database=sabredav;host=localhost
  user: dbusername
  password: dbpassword
  # once again, parameters for DBI driver
  options:
    RaiseError: 1
    AutoCommit: 0

files:
  # data_dir is relative to script location; sould not include
  # ending slash
  data_dir: data
  # if for some reason you don't want to create data_dir
  create_folders: yes
  # by default script removes data_dir and recreates it if necessary
  delete_data_dir_before_create: 1
  # params for File::Path used by make_path and remove_tree subs
  path_options:
    # by default I'd like to know what is happening
    verbose: 1

~~~