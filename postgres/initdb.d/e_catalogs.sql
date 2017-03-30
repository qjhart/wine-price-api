-- Hold all media
SET search_path = catalogs,public,pg_catalog;

create table media (
       media_id uuid primary key default public.gen_random_uuid(),
       title text,
       contents bytea,
       mime_type text,
       thumbnail_png bytea,
       ocr text,
       q tsvector
);

CREATE TRIGGER q_tsvectorupdate BEFORE INSERT OR UPDATE
ON media FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(q, 'public.wine', title, ocr);

CREATE TABLE catalogs (
    catalog_id uuid primary key default public.gen_random_uuid(),
    user_id text,
    title text,
    publisher text,
    year bigint,
    editable boolean,
    media_id uuid references media(media_id),
    created_at timestamp without time zone default now(),
    updated_at timestamp without time zone default now()
);

CREATE FUNCTION q(catalogs) RETURNS tsvector AS $$
  SELECT q from catalogs.media where media_id=$1.media_id;
$$ LANGUAGE SQL IMMUTABLE;

-- (optional) add an index to speed up anticipated query
CREATE INDEX  catalogs_q_idx ON catalogs
  USING GIN (q(catalogs));

CREATE TABLE pages (
    page_id uuid primary key default public.gen_random_uuid(),
    catalog_id uuid references catalogs,
    page bigint,
    media_id uuid references media(media_id),
    editable boolean,
    created_at timestamp without time zone default now()
);

CREATE FUNCTION q(pages) RETURNS tsvector AS $$
  SELECT q from catalogs.media where media_id=$1.media_id;
$$ LANGUAGE SQL IMMUTABLE;

-- (optional) add an index to speed up anticipated query
CREATE INDEX  pages_q_idx ON pages
  USING GIN (q(pages));

CREATE TABLE mark_type (
 type text primary key
);



 CREATE TABLE marks (
    mark_id uuid primary key,
    user_id uuid,
    page_id uuid,
    r double precision,
    c double precision,
    type references mark_type (type);
    wineType,
    color text,
    country text,
    producer text,
    section text,
    vintage integer,
    bottletype text,
    perPrice double precision,
    casePrice double precision,
    created timestamp without time zone,
    updated timestamp without time zone
);

-- CREATE TABLE wine_prices (
--     id bigint NOT NULL,
--     user_id bigint,
--     type wine.type,
--     color wine.color,
--     country text,
--     varietal text,
--     otherdesignation text,
--     brandname text,
--     winery_name text,
--     vintage_date bigint,
--     region text,
--     bottlesize wine.bottle,
--     perprice double precision,
--     caseprice double precision,
--     priceyear bigint,
--     note text,
--     created_at timestamp without time zone,
--     updated_at timestamp without time zone
-- );