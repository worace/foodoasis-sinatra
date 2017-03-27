## FoodOasis Sinatra

Simple Sinatra app for serving postgis queries on foodoasis data

**Local Data Import**

```
CREATEDB=1 DB_NAME=foodoasis_gis DB_USER=$(whoami) DB_HOST=localhost DB_PORT=5432 ./data/import_data.sh
```
