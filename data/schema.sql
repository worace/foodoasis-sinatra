create extension postgis;
create extension "uuid-ossp";

create table locations(
name varchar,
address_1 varchar,
address_2 varchar,
city varchar,
state varchar,
phone varchar,
latitude varchar,
longitude varchar,
website varchar,
location_type varchar,
point geography
);

CREATE INDEX idx_location_point
ON locations
USING GIST(point);
