
DROP SCHEMA IF EXISTS HomeRentals;
CREATE SCHEMA HomeRentals;
USE HomeRentals;


CREATE TABLE Bruker
(
BrukerID INT AUTO_INCREMENT PRIMARY KEY,
Fornavn VARCHAR(50) NOT NULL,
Etternavn VARCHAR(50) NOT NULL,
Epost VARCHAR(100) UNIQUE NOT NULL,
Passord VARCHAR(200) NOT NULL, -- kryptert passord!
TelefonNr VARCHAR(20) NOT NULL, -- VARCHAR for mulighet for tlfnr med landskode
Brukertype ENUM('host','gjest','begge'), -- ENUM er for å angi en av de fast verdiene, hindrer ugyldige verdier og bedre ytelse enn VARCHAR i dette tilfellet
Adresse VARCHAR(200) NOT NULL,
ByNavn VARCHAR(100) NOT NULL, -- kan ikke bruke By som kolonnenavn pga. at det er et reservert ord så vi må bruke ByNavn
Postnr VARCHAR(10) NOT NULL,
OpprettetDato DATE,
Profilbilde VARCHAR(300), -- URL til profilbilde
Gjennomsnittsrating DECIMAL(3,2) DEFAULT 0.00 -- SUM AVG fra Anmeldelse, Stjernerating (tar med 3 sifre hvorav 2 er desimaler). Standardverdi er 0.00.
);


CREATE TABLE Eiendom
(
EiendomID INT AUTO_INCREMENT,
BrukerID INT,
Tittel VARCHAR(300) NOT NULL,
Beskrivelse TEXT,
Adresse VARCHAR(200),
ByNavn VARCHAR(100),
Postnr VARCHAR(10),
PrisPrNatt DECIMAL (10,2) NOT NULL, -- Desimaltall som tar med opptil 10 sifre hvorav 2 er desimaler
MaksAntallGjester INT NOT NULL,
AntallRom INT,
AntallSenger INT,
TypeEiendom ENUM('privat rom','delt rom','helt hjem'),
LagtTilDato DATE,
Gjennomsnittsrating DECIMAL(2,1) DEFAULT 0.0,
CONSTRAINT EiendomPK PRIMARY KEY(EiendomID),
FOREIGN KEY (BrukerID) REFERENCES Bruker(BrukerID)
);


CREATE TABLE Tilgjengelighet
(
TilgjengelighetID INT AUTO_INCREMENT PRIMARY KEY,
EiendomID INT NOT NULL,
StartDato DATE NOT NULL,
SluttDato DATE NOT NULL,
FOREIGN KEY (EiendomID) REFERENCES Eiendom(EiendomID) ON DELETE CASCADE, -- ON DELETE CASCADE gjør at hvis en rad i den primære tabellen slettes, slettes også alle relaterte rader i den sekundære tabellen automatisk
CONSTRAINT unik_tilgjengelighet UNIQUE(EiendomID,StartDato,SluttDato) -- UNIQUE CONSTRAINT for å unngå dobbelbooking
);


CREATE TABLE Fasilitet
(
FasilitetID INT AUTO_INCREMENT PRIMARY KEY,
Fasilitetstype VARCHAR(50) UNIQUE NOT NULL -- Wifi, parkering, badekar osv. UNIQUE for å hindre duplikater
);


CREATE TABLE Eiendom_Fasilitet -- Koblingstabell mellom Eiendom - Fasilitet (mange til mange forhold)
(
EiendomID INT NOT NULL,
FasilitetID INT NOT NULL,
PRIMARY KEY (EiendomID,FasilitetID),
FOREIGN KEY (EiendomID) REFERENCES Eiendom(EiendomID) ON DELETE CASCADE,
FOREIGN KEY (FasilitetID) REFERENCES Fasilitet(FasilitetID) ON DELETE CASCADE
);


CREATE TABLE Eiendom_Bilde
(
BildeID INT AUTO_INCREMENT PRIMARY KEY,
EiendomID INT NOT NULL,
Bilde_URL VARCHAR(300) NOT NULL, -- Link til bildet
Beskrivelse VARCHAR(200),
OpplastetDato TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- DEFAULT CURRENT_TIMESTAMP for å slippe å skrive inn dato og tid manuelt, skjer automatisk
FOREIGN KEY (EiendomID) REFERENCES Eiendom(EiendomID) ON DELETE CASCADE
);


CREATE TABLE Booking
(
BestillingID INT AUTO_INCREMENT PRIMARY KEY,
EiendomID INT NOT NULL,
LeietakerID INT NOT NULL, -- Bruker som leier, brukerID fra Bruker
StartDato DATE NOT NULL,
SluttDato DATE NOT NULL,
TotalBeløp DECIMAL(10,2) NOT NULL,
BookingStatus ENUM('Betalt','Ikke betalt','Kansellert') DEFAULT 'Ikke betalt', -- Blir automatisk 'Ikke betalt' hvis ikke annet er angitt
AntallVoksne INT DEFAULT 1,
AntallBarn INT DEFAULT 0,
Kommentar TEXT, -- Valgfritt (allergier, spesielle ønsker...)
FOREIGN KEY (EiendomID) REFERENCES Eiendom(EiendomID) ON DELETE CASCADE,
FOREIGN KEY (LeietakerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE
);


CREATE TABLE Betaling
(
BetalingID INT AUTO_INCREMENT PRIMARY KEY,
BestillingID INT NOT NULL,
BetalerID INT NOT NULL, -- Bruker som betaler, brukerID fra bruker
Beløp DECIMAL(10,2) NOT NULL,
Betalingsmetode ENUM('Credit','Debit','Apple Pay','PayPal','Vipps') NOT NULL,
BetalingsStatus ENUM('Fullført','Mislykket') DEFAULT 'Mislykket', -- Blir automatisk 'Mislykket' hvis ikke annet er angitt
BetalingsDato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (BestillingID) REFERENCES Booking(BestillingID) ON DELETE CASCADE,
FOREIGN KEY (BetalerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE
);


CREATE TABLE Anmeldelse (
    AnmeldelseID INT AUTO_INCREMENT PRIMARY KEY,
    Anmeldelsestype ENUM('eiendom', 'bruker') NOT NULL,
    FraBrukerID INT NOT NULL,     -- Den som skriver anmeldelsen
    TilBrukerID INT,              -- Brukeren som blir anmeldt (ved bruker-anmeldelse)
    EiendomID INT,                -- Eiendommen som blir anmeldt (ved eiendoms-anmeldelse)
    BestillingID INT NOT NULL,    -- Lenker anmeldelsen til en gjennomført booking
    Kommentar TEXT,
    Stjernerating DECIMAL(2,1) CHECK (Stjernerating BETWEEN 1 AND 5),
    OpprettetDato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (FraBrukerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE,
    FOREIGN KEY (TilBrukerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE,
    FOREIGN KEY (EiendomID) REFERENCES Eiendom(EiendomID) ON DELETE CASCADE,
    FOREIGN KEY (BestillingID) REFERENCES Booking(BestillingID) ON DELETE CASCADE
);


CREATE TABLE Kommunikasjon
(
KommunikasjonID INT AUTO_INCREMENT PRIMARY KEY,
BestillingID INT,
SenderID INT NOT NULL,
MottakerID INT NOT NULL,
Innhold TEXT NOT NULL,
OpprettetDato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY(BestillingID) REFERENCES Booking(BestillingID) ON DELETE CASCADE,
FOREIGN KEY(SenderID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE,
FOREIGN KEY(MottakerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE
);


CREATE TABLE Varsel
(
VarselID INT AUTO_INCREMENT PRIMARY KEY,
BestillingID INT NULL,
Type ENUM('Godkjenning','Avvisning','Kansellering','Melding','Ny anmeldelse','Påminnelse av anmeldelse','Påminnelse av betaling','Andre'), -- Ulike meldingtyper
Innhold TEXT NOT NULL, 
MottakerID INT NOT NULL,
OpprettetDato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
LestDato TIMESTAMP NULL, -- kan være NULL til varselet blir lest
FOREIGN KEY (BestillingID) REFERENCES Booking(BestillingID) ON DELETE SET NULL,
FOREIGN KEY (MottakerID) REFERENCES Bruker(BrukerID) ON DELETE CASCADE
);



