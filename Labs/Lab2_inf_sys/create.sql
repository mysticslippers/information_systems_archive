DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS import_operations;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS coordinates;
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS coordinates (
                                           id SERIAL PRIMARY KEY,
                                           x DOUBLE PRECISION NOT NULL,
                                           y REAL NOT NULL CHECK (y > -976)
);

CREATE TABLE IF NOT EXISTS locations (
                                         id SERIAL PRIMARY KEY,
                                         x BIGINT,
                                         y BIGINT NOT NULL,
                                         z DOUBLE PRECISION NOT NULL
);

CREATE TABLE IF NOT EXISTS routes (
                                      id SERIAL PRIMARY KEY,
                                      name VARCHAR(255) NOT NULL CHECK (trim(name) <> ''),
                                      coordinates_id INTEGER NOT NULL REFERENCES coordinates(id) ON DELETE RESTRICT,
                                      creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      from_location_id INTEGER NOT NULL REFERENCES locations(id) ON DELETE RESTRICT,
                                      to_location_id INTEGER NOT NULL REFERENCES locations(id) ON DELETE RESTRICT,
                                      distance REAL NOT NULL CHECK (distance > 1),
                                      rating DOUBLE PRECISION NOT NULL CHECK (rating > 0)
);

CREATE TABLE IF NOT EXISTS users (
                                     id SERIAL PRIMARY KEY,
                                     username VARCHAR(64) NOT NULL UNIQUE,
                                     email VARCHAR(128) NOT NULL UNIQUE,
                                     password VARCHAR(255) NOT NULL,
                                     role VARCHAR(16) NOT NULL CHECK (role IN ('USER', 'ADMIN'))
);

CREATE TABLE IF NOT EXISTS import_operations (
                                                 id SERIAL PRIMARY KEY,
                                                 username VARCHAR(64) NOT NULL,
                                                 object_type VARCHAR(64) NOT NULL,
                                                 status VARCHAR(32) NOT NULL CHECK (status IN ('IN_PROGRESS', 'SUCCESS', 'FAILED')),
                                                 imported_count INTEGER,
                                                 error_message VARCHAR(2000),
                                                 started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 finished_at TIMESTAMP
);

CREATE TABLE password_reset_tokens (
                                       id BIGSERIAL PRIMARY KEY,
                                       token_hash VARCHAR(64) NOT NULL UNIQUE,
                                       user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                                       created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       expires_at TIMESTAMPTZ NOT NULL,
                                       used_at TIMESTAMPTZ NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_prt_token_hash ON password_reset_tokens (token_hash);
CREATE INDEX IF NOT EXISTS ix_prt_expires_at ON password_reset_tokens (expires_at);
