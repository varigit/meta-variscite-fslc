# Libraries needing versioned symbols, for example mysql, are not
# supported by current version of binutils in krogoth.
#
# When mysql library from MariaDB is compiled with the current
# version of binutils we encounter errors at runtime as seen
# below where php linked to mysql tries to run:

# php: relocation error: php: symbol mysql_server_init, version
# libmysqlclient_16 not defined in file libmysqlclient.so.18
# with link time reference

# Above error appears even though symbols exist in library:
#
#   245: 000000000001ecc0     0 FUNC    GLOBAL DEFAULT   13 mysql_server_init@@libmysqlclient_16
#   279: 000000000001ecc0   297 FUNC    GLOBAL DEFAULT   13 mysql_server_init@@libmysqlclient_18

# The problem results from a bug in binutils that has already been
# fixed upstream as well as on the 2.26 and 2.27 branches. We advance
# the SRCREV on the 2.26 branch used in krogoth release to pick up the fix.

# Details about bug: https://sourceware.org/bugzilla/show_bug.cgi?id=19698

SRCREV = "544ddf9322b1b83982e5cb84a54d084ee7e718ea"
