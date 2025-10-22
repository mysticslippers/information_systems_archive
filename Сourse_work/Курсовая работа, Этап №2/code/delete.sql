DROP TYPE IF EXISTS genders CASCADE;
DROP TYPE IF EXISTS library_status CASCADE;
DROP TYPE IF EXISTS library_card_status CASCADE;
DROP TYPE IF EXISTS booking_status CASCADE;
DROP TYPE IF EXISTS fine_status CASCADE;
DROP TYPE IF EXISTS issuance_status CASCADE;

DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS readers CASCADE;
DROP TABLE IF EXISTS libraries CASCADE;
DROP TABLE IF EXISTS administrators CASCADE;
DROP TABLE IF EXISTS librarians CASCADE;
DROP TABLE IF EXISTS library_cards CASCADE;
DROP TABLE IF EXISTS materials CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS issuances CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS materials_to_libraries CASCADE;
DROP TABLE IF EXISTS materials_to_authors CASCADE;

DROP INDEX IF EXISTS idx_reader_email CASCADE;
DROP INDEX IF EXISTS idx_reader_login CASCADE;
DROP INDEX IF EXISTS idx_addres CASCADE;
DROP INDEX IF EXISTS idx_admin_login CASCADE;
DROP INDEX IF EXISTS idx_librarian_login CASCADE;

DROP TRIGGER IF EXISTS update_staff_count_after_insert_administrators_trigger ON ADMINISTRATORS CASCADE;
DROP TRIGGER IF EXISTS update_staff_count_after_insert_librarians_trigger ON LIBRARIANS CASCADE;
DROP TRIGGER IF EXISTS generate_admin_credentials_trigger ON ADMINISTRATORS CASCADE;
DROP TRIGGER IF EXISTS generate_librarian_credentials_trigger ON LIBRARIANS CASCADE;
DROP TRIGGER IF EXISTS update_bookings_count_trigger ON BOOKINGS CASCADE;
DROP TRIGGER IF EXISTS update_material_copies_trigger ON MATERIALS_TO_LIBRARIES CASCADE;
DROP TRIGGER IF EXISTS set_active_on_card_insert_trigger ON LIBRARY_CARDS CASCADE;
DROP TRIGGER IF EXISTS update_status_on_fine_insert_trigger ON FINES CASCADE;
DROP TRIGGER IF EXISTS set_booking_deadline_trigger ON BOOKINGS CASCADE;
DROP TRIGGER IF EXISTS process_material_return_trigger ON ISSUANCES CASCADE;
DROP TRIGGER IF EXISTS set_issuance_status_trigger ON ISSUANCES CASCADE;
DROP TRIGGER IF EXISTS delete_completed_bookings_trigger ON BOOKINGS CASCADE

DROP FUNCTION IF EXISTS update_staff_count() CASCADE;
DROP FUNCTION IF EXISTS generate_admin_credentials() CASCADE;
DROP FUNCTION IF EXISTS generate_librarian_credentials() CASCADE;
DROP FUNCTION IF EXISTS update_bookings_count() CASCADE;
DROP FUNCTION IF EXISTS update_material_copies() CASCADE;
DROP FUNCTION IF EXISTS update_library_card_status() CASCADE;
DROP FUNCTION IF EXISTS set_booking_deadline() CASCADE;
DROP FUNCTION IF EXISTS process_material_return() CASCADE;
DROP FUNCTION IF EXISTS set_issuance_status() CASCADE;
DROP FUNCTION IF EXISTS delete_completed_bookings() CASCADE;