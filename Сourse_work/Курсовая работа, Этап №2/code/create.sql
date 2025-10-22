CREATE TYPE GENDERS AS ENUM(
    'MALE',
    'FEMALE',
    'NOT STATED'
);

CREATE TYPE LIBRARY_STATUS AS ENUM(
    'ОТКРЫТО',
    'ЗАКРЫТО'
);

CREATE TYPE LIBRARY_CARD_STATUS AS ENUM(
    'АКТИВЕН',
    'ЕСТЬ ШТРАФ',
    'НЕ АКТИВЕН'
);

CREATE TYPE BOOKING_STATUS AS ENUM(
    'ЗАБРОНИРОВАН',
    'ПРОСРОЧЕН',
    'ЗАВЕРШЕНА'
);

CREATE TYPE ISSUANCE_STATUS AS ENUM(
    'ВЫДАН',
    'ВОЗВРАТ'
);

CREATE TYPE FINE_STATUS AS ENUM(
    'ВЫСТАВЛЕН',
    'ОПЛАЧЕН',
    'ПРОСРОЧЕН'
);

CREATE TABLE IF NOT EXISTS PEOPLE(
    id BIGSERIAL PRIMARY KEY,
    surname VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    birth_date DATE NOT NULL CONSTRAINT minimum_age CHECK (birth_date <= (CURRENT_DATE - INTERVAL '18 years')),
    gender GENDERS NOT NULL
);

CREATE TABLE IF NOT EXISTS READERS(
    id BIGSERIAL PRIMARY KEY,
    people_id BIGINT REFERENCES PEOPLE (id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    login VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    CONSTRAINT readble_login CHECK (char_length(login) < 100),
    CONSTRAINT valid_email CHECK (email ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_reader_email ON READERS USING btree (email);
CREATE UNIQUE INDEX IF NOT EXISTS idx_reader_login ON READERS USING btree (login);

CREATE TABLE IF NOT EXISTS LIBRARIES(
    id BIGSERIAL PRIMARY KEY,
    addres JSONB NOT NULL UNIQUE,
    staff_number SMALLINT NOT NULL,
    status LIBRARY_STATUS NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_addres ON LIBRARIES USING btree (((addres ->> 'street') :: VARCHAR(255)));

CREATE TABLE IF NOT EXISTS ADMINISTRATORS(
    id BIGSERIAL PRIMARY KEY,
    people_id BIGINT REFERENCES PEOPLE (id) ON DELETE CASCADE,
    library_id BIGINT REFERENCES LIBRARIES (id) ON DELETE RESTRICT,
    login VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    CONSTRAINT valid_login CHECK (login ~ '^admin[0-9]{6,}$'),
    CONSTRAINT valid_password CHECK (password ~ '[0-9]{6,}$')
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_admin_login ON ADMINISTRATORS USING btree (login);

CREATE TABLE IF NOT EXISTS LIBRARIANS(
    id BIGSERIAL PRIMARY KEY,
    people_id BIGINT REFERENCES PEOPLE (id) ON DELETE CASCADE,
    library_id BIGINT REFERENCES LIBRARIES (id) ON DELETE RESTRICT,
    login VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    CONSTRAINT valid_login CHECK (login ~ '^librarian[0-9]{6,}$'),
    CONSTRAINT valid_password CHECK (password ~ '[0-9]{6,}$')
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_librarian_login ON LIBRARIANS USING btree (login);

CREATE TABLE IF NOT EXISTS LIBRARY_CARDS(
    id BIGSERIAL PRIMARY KEY,
    reader_id BIGINT REFERENCES READERS (id) ON DELETE RESTRICT,
    surname VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    status LIBRARY_CARD_STATUS,
    bookings_number SMALLINT
);

CREATE TABLE IF NOT EXISTS MATERIALS(
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    publishing_house VARCHAR(255) NOT NULL,
    publication_year DATE NOT NULL,
    genre VARCHAR(255) NOT NULL,
    language VARCHAR(255) NOT NULL,
    isbn VARCHAR(17) NOT NULL,
    copies SMALLINT
);

CREATE TABLE IF NOT EXISTS BOOKINGS(
    id BIGSERIAL PRIMARY KEY,
    reader_id BIGINT REFERENCES READERS (id) ON DELETE RESTRICT,
    librarian_id BIGINT REFERENCES LIBRARIANS (id) ON DELETE RESTRICT,
    library_id BIGINT REFERENCES LIBRARIES (id) ON DELETE RESTRICT,
    booking_date DATE NOT NULL,
    booking_deadline DATE,
    status BOOKING_STATUS NOT NULL,
    material_id BIGINT REFERENCES MATERIALS (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ISSUANCES(
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT REFERENCES BOOKINGS (id) ON DELETE CASCADE,
    issuance_date DATE NOT NULL,
    status ISSUANCE_STATUS
);

CREATE TABLE IF NOT EXISTS AUTHORS(
    id BIGSERIAL PRIMARY KEY,
    surname VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS FINES(
    id BIGSERIAL PRIMARY KEY,
    library_card_id BIGINT REFERENCES LIBRARY_CARDS (id) ON DELETE RESTRICT,
    issuance_id BIGINT REFERENCES ISSUANCES (id) ON DELETE RESTRICT,
    description TEXT NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    status FINE_STATUS NOT NULL,
    CONSTRAINT readable_description CHECK (char_length(description) < 200)
);

CREATE TABLE IF NOT EXISTS MATERIALS_TO_LIBRARIES(
    material_id BIGINT REFERENCES MATERIALS (id) ON DELETE CASCADE,
    library_id BIGINT REFERENCES LIBRARIES (id) ON DELETE RESTRICT,
    PRIMARY KEY (material_id, library_id)
);

CREATE TABLE IF NOT EXISTS MATERIALS_TO_AUTHORS(
    material_id BIGINT REFERENCES MATERIALS (id) ON DELETE CASCADE,
    author_id BIGINT REFERENCES AUTHORS (id) ON DELETE RESTRICT,
    PRIMARY KEY (material_id, author_id)
);