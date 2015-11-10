whoami
for i in test production development;do createdb vmdb_$i;done
psql -c "create role root login password 'smartvm'"
psql -c "alter database vmdb_development owner to root"
