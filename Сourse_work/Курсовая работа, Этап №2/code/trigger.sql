CREATE OR REPLACE FUNCTION update_staff_count()
    RETURNS TRIGGER AS
    $$
    BEGIN
        UPDATE LIBRARIES
        SET staff_number = (
                SELECT COUNT(*) FROM ADMINISTRATORS WHERE library_id = NEW.library_id
            ) + (
                SELECT COUNT(*) FROM LIBRARIANS WHERE library_id = NEW.library_id
            )
        WHERE id = NEW.library_id;
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER update_staff_count_after_insert_administrators_trigger
AFTER INSERT ON ADMINISTRATORS
FOR EACH ROW
EXECUTE FUNCTION update_staff_count();

CREATE TRIGGER update_staff_count_after_insert_librarians_trigger
AFTER INSERT ON LIBRARIANS
FOR EACH ROW
EXECUTE FUNCTION update_staff_count();

CREATE OR REPLACE FUNCTION generate_admin_credentials()
    RETURNS TRIGGER AS
    $$
    DECLARE
        rnd_suffix TEXT;
        rnd_password TEXT;
    BEGIN
        LOOP
            rnd_suffix := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
            EXIT WHEN NOT EXISTS (
                SELECT 1 FROM ADMINISTRATORS WHERE login = 'admin' || rnd_suffix
            );
        END LOOP;

        IF NEW.login IS NULL OR NEW.login = '' THEN
            NEW.login := 'admin' || rnd_suffix;
        END IF;

        IF NEW.password IS NULL OR NEW.password = '' THEN
            rnd_password := LPAD(FLOOR(RANDOM() * 1000000000)::TEXT, 6, '0');
            NEW.password := rnd_password;
        END IF;
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER generate_admin_credentials_trigger
BEFORE INSERT ON ADMINISTRATORS
FOR EACH ROW
EXECUTE FUNCTION generate_admin_credentials();

CREATE OR REPLACE FUNCTION generate_librarian_credentials()
    RETURNS TRIGGER AS
    $$
    DECLARE
        rnd_suffix TEXT;
        rnd_password TEXT;
    BEGIN
        LOOP
            rnd_suffix := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
            EXIT WHEN NOT EXISTS (
                SELECT 1 FROM LIBRARIANS WHERE login = 'librarian' || rnd_suffix
            );
        END LOOP;

        IF NEW.login IS NULL OR NEW.login = '' THEN
            NEW.login := 'librarian' || rnd_suffix;
        END IF;

        IF NEW.password IS NULL OR NEW.password = '' THEN
            rnd_password := LPAD(FLOOR(RANDOM() * 1000000000)::TEXT, 6, '0');
            NEW.password := rnd_password;
        END IF;
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER generate_librarian_credentials_trigger
BEFORE INSERT ON LIBRARIANS
FOR EACH ROW
EXECUTE FUNCTION generate_librarian_credentials();

CREATE OR REPLACE FUNCTION update_bookings_count()
    RETURNS TRIGGER AS
    $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE LIBRARY_CARDS
            SET bookings_number = (
                SELECT COUNT(*)
                FROM BOOKINGS
                WHERE reader_id = NEW.reader_id
            )
            WHERE reader_id = NEW.reader_id;

        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE LIBRARY_CARDS
            SET bookings_number = (
                SELECT COUNT(*)
                FROM BOOKINGS
                WHERE reader_id = OLD.reader_id
            )
            WHERE reader_id = OLD.reader_id;

        ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.reader_id <> OLD.reader_id) THEN
            UPDATE LIBRARY_CARDS
            SET bookings_number = (
                SELECT COUNT(*)
                FROM BOOKINGS
                WHERE reader_id = OLD.reader_id
            )
            WHERE reader_id = OLD.reader_id;

            UPDATE LIBRARY_CARDS
            SET bookings_number = (
                SELECT COUNT(*)
                FROM BOOKINGS
                WHERE reader_id = NEW.reader_id
            )
            WHERE reader_id = NEW.reader_id;
        ELSE
            UPDATE LIBRARY_CARDS
            SET bookings_number = (
                SELECT COUNT(*)
                FROM BOOKINGS
                WHERE reader_id = NEW.reader_id
            )
            WHERE reader_id = NEW.reader_id;
            END IF;
        END IF;
        RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER update_bookings_count_trigger
AFTER INSERT OR DELETE OR UPDATE ON BOOKINGS
FOR EACH ROW
EXECUTE FUNCTION update_bookings_count();

CREATE OR REPLACE FUNCTION update_material_copies()
    RETURNS TRIGGER AS
    $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE MATERIALS
            SET copies = (
                SELECT COUNT(*)
                FROM MATERIALS_TO_LIBRARIES
                WHERE material_id = NEW.material_id
            )
            WHERE id = NEW.material_id;

        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE MATERIALS
            SET copies = (
                SELECT COUNT(*)
                FROM MATERIALS_TO_LIBRARIES
                WHERE material_id = OLD.material_id
            )
            WHERE id = OLD.material_id;
        END IF;
        RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER update_material_copies_trigger
AFTER INSERT OR DELETE ON MATERIALS_TO_LIBRARIES
FOR EACH ROW
EXECUTE FUNCTION update_material_copies();

CREATE OR REPLACE FUNCTION update_library_card_status()
    RETURNS TRIGGER AS
    $$
    BEGIN
        IF (TG_TABLE_NAME = 'library_cards' AND TG_OP = 'INSERT') THEN
            UPDATE LIBRARY_CARDS
            SET status = 'АКТИВЕН'
            WHERE id = NEW.id;

        ELSIF (TG_TABLE_NAME = 'fines' AND TG_OP = 'INSERT') THEN
            IF (NEW.payment_date < CURRENT_DATE) THEN
                UPDATE LIBRARY_CARDS
                SET status = 'НЕ АКТИВЕН'
                WHERE id = NEW.library_card_id;
            ELSE
                UPDATE LIBRARY_CARDS
                SET status = 'ЕСТЬ ШТРАФ'
                WHERE id = NEW.library_card_id;
            END IF;

        ELSIF (TG_TABLE_NAME = 'fines' AND TG_OP = 'UPDATE') THEN
            IF (NEW.status = 'ОПЛАЧЕН') THEN
                PERFORM 1
                FROM FINES
                WHERE library_card_id = NEW.library_card_id
                AND status IN ('ВЫСТАВЛЕН', 'ПРОСРОЧЕН')
                LIMIT 1;

            IF NOT FOUND THEN
                UPDATE LIBRARY_CARDS
                SET status = 'АКТИВЕН'
                WHERE id = NEW.library_card_id;
            END IF;
            END IF;
        END IF;
        RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER set_active_on_card_insert_trigger
AFTER INSERT ON LIBRARY_CARDS
FOR EACH ROW
EXECUTE FUNCTION update_library_card_status();

CREATE TRIGGER update_status_on_fine_insert_trigger
AFTER INSERT OR UPDATE ON FINES
FOR EACH ROW
EXECUTE FUNCTION update_library_card_status();

CREATE OR REPLACE FUNCTION set_booking_deadline()
    RETURNS TRIGGER AS
    $$
    BEGIN
        NEW.booking_deadline := NEW.booking_date + INTERVAL '14 days';
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER set_booking_deadline_trigger
BEFORE INSERT ON BOOKINGS
FOR EACH ROW
EXECUTE FUNCTION set_booking_deadline();

CREATE OR REPLACE FUNCTION process_material_return()
    RETURNS TRIGGER AS
    $$
    DECLARE
        v_booking RECORD;
        unpaid_fines INT;
    BEGIN
        IF (NEW.status = 'ВОЗВРАТ') THEN
            SELECT * INTO v_booking
            FROM BOOKINGS
            WHERE id = NEW.booking_id;

            SELECT COUNT(*) INTO unpaid_fines
            FROM FINES
            WHERE issuance_id = NEW.id
                AND status IN ('ВЫСТАВЛЕН', 'ПРОСРОЧЕН');

            IF unpaid_fines = 0 THEN
                INSERT INTO MATERIALS_TO_LIBRARIES (material_id, library_id)
                VALUES (v_booking.material_id, v_booking.library_id)
                ON CONFLICT DO NOTHING;

                UPDATE BOOKINGS
                SET status = 'ЗАВЕРШЕНА'
                WHERE id = v_booking.id;
            END IF;
        END IF;
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER process_material_return_trigger
AFTER UPDATE ON ISSUANCES
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION process_material_return();

CREATE OR REPLACE FUNCTION set_issuance_status()
    RETURNS TRIGGER AS
    $$
    BEGIN
        NEW.status := 'ВЫДАН';
        RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER set_issuance_status_trigger
BEFORE INSERT ON ISSUANCES
FOR EACH ROW
EXECUTE FUNCTION set_issuance_status();

CREATE OR REPLACE FUNCTION delete_completed_bookings()
    RETURNS TRIGGER AS
    $$
    BEGIN
        DELETE FROM BOOKINGS
        WHERE status = 'ЗАВЕРШЕНА';
        RETURN NULL;
    END;
    $$
    LANGUAGE plpgsql;

CREATE TRIGGER delete_completed_bookings_trigger
AFTER UPDATE ON BOOKINGS
FOR EACH STATEMENT
EXECUTE FUNCTION delete_completed_bookings();
