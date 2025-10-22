INSERT INTO people (surname, name, middle_name, birth_date, gender) VALUES
('Иванов', 'Иван', 'Иванович', '1990-03-15', 'MALE'),
('Петрова', 'Анна', 'Сергеевна', '1995-07-22', 'FEMALE'),
('Сидоров', 'Павел', 'Николаевич', '1988-11-01', 'MALE'),
('Кузнецова', 'Мария', 'Игоревна', '1992-04-10', 'FEMALE'),
('Орлова', 'Елена', 'Андреевна', '1985-12-05', 'FEMALE'),
('Фёдоров', 'Михаил', 'Олегович', '1991-09-18', 'MALE'),
('Ковалев', 'Дмитрий', 'Викторович', '1986-02-11', 'MALE'),
('Громова', 'Людмила', 'Петровна', '1993-05-25', 'FEMALE'),
('Алексеев', 'Роман', 'Ильич', '1990-08-09', 'MALE'),
('Семенова', 'Татьяна', 'Евгеньевна', '1989-10-19', 'FEMALE');

INSERT INTO libraries (addres, staff_number, status) VALUES
('{"city": "Москва", "street": "Ленина", "building": "10"}', 0, 'ОТКРЫТО'),
('{"city": "Санкт-Петербург", "street": "Невский", "building": "25"}', 0, 'ОТКРЫТО');

INSERT INTO administrators (people_id, library_id) VALUES
(1, 1),
(2, 2);

INSERT INTO librarians (people_id, library_id) VALUES
(3, 1),
(4, 2),
(5, 1);

INSERT INTO readers (people_id, email, login, password) VALUES
(6, 'mikhail.fedorov@mail.ru', 'misha91', 'pass123'),
(7, 'dmitry.kovalev@mail.ru', 'dmit86', 'pass321'),
(8, 'ludmila.gromova@mail.ru', 'luda93', 'pw12345'),
(9, 'roman.alexeev@mail.ru', 'roma90', 'pw98765'),
(10, 'tatyana.semenova@mail.ru', 'tanya89', 'tpass999');

INSERT INTO library_cards (reader_id, surname, name, middle_name) VALUES
(1, 'Фёдоров', 'Михаил', 'Олегович'),
(2, 'Ковалев', 'Дмитрий', 'Викторович'),
(3, 'Громова', 'Людмила', 'Петровна'),
(4, 'Алексеев', 'Роман', 'Ильич'),
(5, 'Семенова', 'Татьяна', 'Евгеньевна');

INSERT INTO authors (surname, name, middle_name) VALUES
('Толстой', 'Лев', 'Николаевич'),
('Достоевский', 'Фёдор', 'Михайлович'),
('Булгаков', 'Михаил', 'Афанасьевич'),
('Оруэлл', 'Джордж', ''),
('Пушкин', 'Александр', 'Сергеевич');

INSERT INTO materials (title, publishing_house, publication_year, genre, language, isbn, copies) VALUES
('Война и мир', 'АСТ', '2010-01-01', 'Роман', 'Русский', '978-5-17-066774-2', 0),
('Преступление и наказание', 'Эксмо', '2015-01-01', 'Роман', 'Русский', '978-5-699-76993-5', 0),
('Мастер и Маргарита', 'Азбука', '2018-01-01', 'Фантастика', 'Русский', '978-5-389-07436-4', 0),
('1984', 'Penguin', '2019-01-01', 'Антиутопия', 'Английский', '978-0-452-28423-4', 0),
('Евгений Онегин', 'АСТ', '2012-01-01', 'Поэма', 'Русский', '978-5-17-072020-1', 0);

INSERT INTO materials_to_authors (material_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO materials_to_libraries (material_id, library_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 1);

INSERT INTO bookings (reader_id, librarian_id, library_id, booking_date, status, material_id) VALUES
(1, 1, 1, '2025-10-01', 'ЗАБРОНИРОВАН', 1),
(2, 2, 2, '2025-10-05', 'ЗАБРОНИРОВАН', 3),
(3, 1, 1, '2025-10-07', 'ПРОСРОЧЕН', 2);

INSERT INTO issuances (booking_id, issuance_date) VALUES
(1, '2025-10-02'),
(2, '2025-10-06'),
(3, '2025-10-08');

INSERT INTO fines (library_card_id, issuance_id, description, due_date, payment_date, status) VALUES
(1, 1, 'Просрочка возврата книги', '2025-10-15', '2025-10-20', 'ОПЛАЧЕН'),
(2, 2, 'Порча книги', '2025-10-10', '2025-10-05', 'ПРОСРОЧЕН'),
(3, 3, 'Просрочка возврата', '2025-10-14', '2025-10-15', 'ВЫСТАВЛЕН');


UPDATE issuances SET status = 'ВОЗВРАТ' WHERE id = 1;
UPDATE issuances SET status = 'ВОЗВРАТ' WHERE id = 2;
UPDATE issuances SET status = 'ВОЗВРАТ' WHERE id = 3;
