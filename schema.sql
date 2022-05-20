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

CREATE TABLE country_visits(
    id serial PRIMARY KEY,
    country_id integer NOT NULL REFERENCES countries(id),
    journey_id integer NOT NULL REFERENCES journeys(id) ON DELETE CASCADE
);

CREATE TABLE location_visits(
    id serial PRIMARY KEY,
    location_id integer NOT NULL REFERENCES locations(id),
    country_visit_id integer NOT NULL REFERENCES country_visits(id) ON DELETE CASCADE
);