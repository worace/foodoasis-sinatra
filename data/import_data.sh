#! /bin/bash

if [ "$CREATEDB" -eq "1" ]; then
    dropdb $DB_NAME
    createdb $DB_NAME
fi

psql -d $DB_NAME \
     -h $DB_HOST \
     -U $DB_USER \
     -p $DB_PORT \
     -f ./data/schema.sql

ruby data/combine_datasets.rb | \
    psql -d $DB_NAME \
         -h $DB_HOST \
         -U $DB_USER \
         -p $DB_PORT \
         -c "COPY locations FROM STDIN DELIMITER ',' CSV HEADER;"

psql -d $DB_NAME \
     -h $DB_HOST \
     -U $DB_USER \
     -p $DB_PORT \
     -c "UPDATE LOCATIONS SET point = ST_Point(longitude::numeric, latitude::numeric);"

psql -d $DB_NAME \
     -h $DB_HOST \
     -U $DB_USER \
     -p $DB_PORT \
     -c "CLUSTER locations USING idx_location_point;"
psql -d $DB_NAME \
     -h $DB_HOST \
     -U $DB_USER \
     -p $DB_PORT \
     -c "VACUUM ANALYZE locations;"
