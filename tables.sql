create table regions
(
    country_name varchar,
    country_code varchar(3) not null
        primary key,
    region       varchar,
    income_group varchar
);

alter table regions
    owner to postgres;

create table forest_area
(
    country_code     varchar(3)
        references regions,
    country_name     varchar,
    year             smallint
        constraint forest_area_year_check
            check (year > 0),
    forest_area_sqkm double precision
        constraint forest_area_forest_area_sqkm_check
            check (forest_area_sqkm > (0.0)::double precision)
);

alter table forest_area
    owner to postgres;

create table land_area
(
    country_code     varchar(3) not null
        references regions,
    country_name     varchar    not null,
    year             smallint
        constraint land_area_year_check
            check (year > 0),
    total_area_sq_mi double precision
        constraint land_area_total_area_sq_mi_check
            check (total_area_sq_mi > (0.0)::double precision)
);

alter table land_area
    owner to postgres;

