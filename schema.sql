CREATE TABLE journeys(
    id serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE countries(
    id serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE locations(
    id serial PRIMARY KEY,
    name text NOT NULL,
    country_id integer NOT NULL REFERENCES countries(id) ON DELETE CASCADE
);

CREATE TABLE countries_journeys(
    id serial PRIMARY KEY,
    country_id integer NOT NULL REFERENCES countries(id),
    journey_id integer NOT NULL REFERENCES journeys(id) ON DELETE CASCADE
);

CREATE TABLE locations_journeys(
    id serial PRIMARY KEY,
    location_id integer NOT NULL REFERENCES locations(id),
    journey_id integer NOT NULL REFERENCES journeys(id) ON DELETE CASCADE
);