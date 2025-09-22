-- Testdata for bruker 1 (gjest)
INSERT INTO Bruker (Fornavn, Etternavn, Epost, Passord, TelefonNr, Brukertype, Adresse, ByNavn, Postnr, OpprettetDato, Profilbilde)
VALUES ('Ola', 'Nordmann', 'ola.nordmann@example.com', 'passord123', '+4798765432', 'gjest', 'Osloveien 10', 'Oslo', '0150', CURDATE(), 'https://linktilbilde.no/1');

-- Testdata for bruker 2 (host)
INSERT INTO Bruker (Fornavn, Etternavn, Epost, Passord, TelefonNr, Brukertype, Adresse, ByNavn, Postnr, OpprettetDato, Profilbilde)
VALUES ('Kari', 'Hansen', 'kari.hansen@example.com', 'passord456', '+4787654321', 'host', 'Bergenveien 5', 'Bergen', '5000', CURDATE(), 'https://linktilbilde.no/2');

-- Sett inn ny bruker (med brukertype ‘begge’), passord lagres som ukryptert tekst siden vi får ikke kryptert det i dette prosjektet.
INSERT INTO Bruker (Fornavn, Etternavn, Epost, Passord, TelefonNr, Brukertype, Adresse, ByNavn, Postnr, OpprettetDato, Profilbilde)
VALUES ('Jens', 'Jensen', 'nybruker@example.com', 'passord000', '+4788888888', 'begge', 'Osloveien 1', 'Oslo', '0575', CURDATE(), 'https://linktilbilde.no');

-- Hvis Antall > 0 så viser får bruker beskjed om at e-postadressen er allerede i bruk
SELECT COUNT(*) AS Antall FROM Bruker 
WHERE Epost = 'nybruker@example.com';

-- Spørring for å bekrefte at brukeren er registrert, for å blant annet kunne gi brukeren melding om vellykket registrering.
SELECT * 
FROM Bruker 
WHERE Epost = 'nybruker@example.com';
