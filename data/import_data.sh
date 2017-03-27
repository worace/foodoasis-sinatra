#! /bin/bash

dropdb foodoasis_gis
createdb foodoasis_gis

DB_NAME=foodoasis_gis

psql -d $DB_NAME -f ./data/schema.sql

ruby data/combine_datasets.rb | \
    psql -d $DB_NAME \
         -c "COPY locations FROM STDIN DELIMITER ',' CSV HEADER;"

psql -d $DB_NAME -c "CLUSTER locations USING idx_location_point;"
psql -d $DB_NAME -c "VACUUM ANALYZE locations;"
