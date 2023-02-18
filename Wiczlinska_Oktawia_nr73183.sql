-- Tworzenie bazy danych
CREATE DATABASE Zoo3;
GO
USE Zoo3;
GO

-- Tworzenie tabeli Gatunki
CREATE TABLE Gatunki (
    ID_Gatunku INT PRIMARY KEY,
    NazwaGat VARCHAR(255),
    Opis TEXT
);

ALTER TABLE Gatunki ADD CONSTRAINT check_name CHECK (Nazwa LIKE '[A-Z][a-z]+');

-- Tworzenie tabeli Opiekunowie
CREATE TABLE Opiekunowie (
    ID_Opiekuna INT PRIMARY KEY,
    Imie VARCHAR(255),
    Nazwisko VARCHAR(255),
    Data_Urodzenia DATE,
    Telefon VARCHAR(255)
);

ALTER TABLE Opiekunowie ADD CONSTRAINT check_phone CHECK (Telefon LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
ALTER TABLE Opiekunowie ADD CONSTRAINT default_birthdate DEFAULT ('1970-01-01') FOR Data_Urodzenia;

-- Tworzenie tabeli Zwierzeta
CREATE TABLE Zwierzeta (
    ID_Zwierze INT PRIMARY KEY,
    ID_Gatunku INT,
    ID_Opiekuna INT,
    ImieOp VARCHAR(255),
    Data_Urodzenia DATE,
    Waga FLOAT,
    FOREIGN KEY (ID_Gatunku) REFERENCES Gatunki (ID_Gatunku),
    FOREIGN KEY (ID_Opiekuna) REFERENCES Opiekunowie (ID_Opiekuna)
);

ALTER TABLE Zwierzeta ADD CONSTRAINT check_weight CHECK (Waga > 0);
ALTER TABLE Zwierzeta ADD CONSTRAINT default_species DEFAULT (SELECT ID_Gatunku FROM Gatunki WHERE Nazwa = 'Lion') FOR ID_Gatunku;


-- Tworzenie tabeli Wystawy
CREATE TABLE Wystawy (
    ID_Wystawy INT PRIMARY KEY,
    Nazwa VARCHAR(255),
    Opis TEXT
);

ALTER TABLE Wystawy ADD CONSTRAINT default_description DEFAULT ('No description available') FOR Opis;


-- Tworzenie tabeli Wystawy_Zwierzeta
CREATE TABLE Wystawy_Zwierzeta (
    ID_Wystawy INT,
    ID_Zwierzeta INT,
    FOREIGN KEY (ID_Wystawy) REFERENCES Wystawy(ID_Wystawy),
    FOREIGN KEY (ID_Zwierzeta) REFERENCES Zwierzeta(ID_Zwierze)
);

 GO

-- Dodanie widoku po³¹czaj¹cego dane z co najmniej 4 tabelami

CREATE VIEW vw_animal_details 
AS 
SELECT Z.ID_Zwierze, Z.ImieOp, G.NazwaGat, W.Nazwa, O.Imie, O.Nazwisko
FROM Zwierzeta Z 
JOIN Gatunki G ON Z.ID_Gatunku = G.ID_Gatunku
JOIN Wystawy_Zwierzeta WZ ON Z.ID_Zwierze = WZ.ID_Zwierzeta
JOIN Wystawy W ON WZ.ID_Wystawy = W.ID_Wystawy
JOIN Opiekunowie O ON Z.ID_Opiekuna = O.ID_Opiekuna;

GO

-- Dodanie widoku zgrupowanego

CREATE VIEW vw_species_count AS
SELECT G.NazwaGat, COUNT(Z.ID_Zwierze) as Liczba_zwierzat
FROM Zwierzeta Z
JOIN Gatunki G ON Z.ID_Gatunku = G.ID_Gatunku
GROUP BY G.NazwaGat;

GO

-- Dodanie widoku z wykorzystaniem funkcji analitycznych i partycjonowania
CREATE VIEW vw_animal_weights AS
SELECT ID_Zwierze, ImieOp, Waga,
ROW_NUMBER() OVER (PARTITION BY ID_Gatunku ORDER BY Waga DESC) AS Ranking_wag
FROM Zwierzeta;

GO

-- Dodanie funkcji skalarnej z co najmniej 2 parametrami
CREATE FUNCTION fn_calculate_age (@birthdate DATE, @currentdate DATE)
RETURNS INT
BEGIN
RETURN DATEDIFF(year, @birthdate, @currentdate)
END

GO

-- Wprowadzanie przyk³adowych danych do tabeli Zwierzeta
INSERT INTO Zwierzeta (ID_Zwierze, ID_Gatunku, ID_Opiekuna, ImieOp, Data_Urodzenia, Waga) VALUES (1, 1, 1, 'Simba', '2010-01-01', 100);
INSERT INTO Zwierzeta (ID_Zwierze, ID_Gatunku, ID_Opiekuna, ImieOp, Data_Urodzenia, Waga) VALUES (2, 2, 2, 'Misiu', '2020-03-20', 20);

-- Wprowadzanie przyk³adowych danych do tabeli Gatunki
INSERT INTO Gatunki (ID_Gatunku, NazwaGat, Opis) VALUES (1, 'Lion', 'The king of the jungle');
INSERT INTO Gatunki (ID_Gatunku, NazwaGat, Opis) VALUES (2, 'Elephant', 'The largest land animal');

-- Wprowadzanie przyk³adowych danych do tabeli Wystawy
INSERT INTO Wystawy (ID_Wystawy, Nazwa, Opis) VALUES (1, 'African Savannah', 'See lions, elephants and other African animals in their natural habitat');
INSERT INTO Wystawy (ID_Wystawy, Nazwa, Opis) VALUES (2, 'Aquatic World', 'Explore the underwater world with sharks, dolphins and more');

-- Wprowadzanie przyk³adowych danych do tabeli Opiekunowie
INSERT INTO Opiekunowie (ID_Opiekuna, Imie, Nazwisko, Data_Urodzenia, Telefon) VALUES (1, 'John', 'Smith', '1980-01-01', '555-555-5555');
INSERT INTO Opiekunowie (ID_Opiekuna, Imie, Nazwisko, Data_Urodzenia, Telefon) VALUES (2, 'Jane', 'Doe', '1985-02-02', '555-555-5556');

-- Wprowadzanie przyk³adowych danych do tabeli Wystawy_Zwierzeta
INSERT INTO Wystawy_Zwierzeta (ID_Wystawy, ID_Zwierzeta) VALUES (1, 1);
INSERT INTO Wystawy_Zwierzeta (ID_Wystawy, ID_Zwierzeta) VALUES (2, 1);

-- Dodanie indeksów typu NONCLUSTERED INDEX
CREATE NONCLUSTERED INDEX idx_species ON Zwierzeta (ID_Gatunku);
CREATE NONCLUSTERED INDEX idx_keeper ON Zwierzeta (ID_Opiekuna);
CREATE NONCLUSTERED INDEX idx_exhibition ON Wystawy_Zwierzeta (ID_Wystawy);

------

GO

-- Dodanie funkcji tabelarycznej z co najmniej 2 parametrami
CREATE FUNCTION fn_get_animals_by_species (@species VARCHAR(255))
RETURNS TABLE
AS
RETURN (SELECT ImieOp FROM Zwierzeta Z JOIN Gatunki G ON Z.ID_Gatunku = G.ID_Gatunku WHERE G.NazwaGat = @species)

GO

-- Dodanie widoku wykorzystuj¹cego funkcjê skalarn¹ lub tabelaryczn¹
CREATE VIEW vw_animal_ages AS
SELECT ID_Zwierze, ImieOp, Data_Urodzenia, dbo.fn_calculate_age(Data_Urodzenia, GETDATE()) as Wiek
FROM Zwierzeta;

GO

-- Dodanie procedury sk³adowanej z minimum 4 parametrami
CREATE PROCEDURE sp_add_animal (@name VARCHAR(255), @species INT, @birthdate DATE, @weight FLOAT)
AS
BEGIN
BEGIN TRY
INSERT INTO Zwierzeta (ImieOp, ID_Gatunku, Data_Urodzenia, Waga) VALUES (@name, @species, @birthdate, @weight)
END TRY
BEGIN CATCH
PRINT 'Nie mo¿na dodaæ zwierzêcia. SprawdŸ, czy podano poprawne dane oraz czy gatunek istnieje.'
END CATCH
END