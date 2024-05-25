

CREATE TABLE TiposTarifa (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255)
);
CREATE TABLE TiposUnidades (
    Id INT PRIMARY KEY,
    Tipo VARCHAR(255)
);

CREATE TABLE TiposElemento (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255),
	idTipoUnidad INT FOREIGN KEY REFERENCES TiposUnidades(Id),
	EsFijo BIT
);


CREATE TABLE ElementoDeTipoTarifa (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    idTipoTarifa INT FOREIGN KEY REFERENCES TiposTarifa(Id),
    idTipoElemento INT FOREIGN KEY REFERENCES TiposElemento(Id),
	Valor INT,
);

CREATE TABLE TipoRelacionesFamiliares (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255)
);

-------------------------------------------


CREATE TABLE Clientes (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    Identificacion INT UNIQUE,
    Nombre VARCHAR(255),
	FechaOperacion DATE
);

CREATE TABLE Contratos (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    Numero BIGINT UNIQUE,
    DocIdCliente INT FOREIGN KEY REFERENCES Clientes (identificacion),
    TipoTarifa INT FOREIGN KEY REFERENCES TiposTarifa (Id),
	FechaOperacion DATE
);

CREATE TABLE LlamadaTelefonica (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    NumeroDe BIGINT FOREIGN KEY REFERENCES Contratos(Numero),           
    NumeroA  BIGINT,
    Inicio DATETIME,
    Fin  DATETIME,
	FechaOperacion DATE
);

CREATE TABLE PagoFactura (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    Numero BIGINT FOREIGN KEY REFERENCES Contratos(Numero),
	FechaOperacion DATE
);

CREATE TABLE  RelacionFamiliar (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    DocIdDe INT FOREIGN KEY REFERENCES Clientes(identificacion),
    DocIdA INT,
    idTipoRelacion INT FOREIGN KEY REFERENCES TipoRelacionesFamiliares (Id),
	FechaOperacion DATE,
	
);

CREATE TABLE  UsoDatos (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    NumeroContrato  BIGINT FOREIGN KEY REFERENCES Contratos(Numero),
    QGigas DECIMAL(4,2),
	FechaOperacion DATE
);

CREATE TABLE ResultadosLlamadas (
        FechaOperacion DATE,
        Id INT,
        NumeroDe BIGINT,
        NumeroA BIGINT,
        DiferenciaMinutos INT
    );

CREATE TABLE Llamadas800 (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        FechaOperacion DATE,
        DuracionMinutos INT,
        Emisor BIGINT,
        Receptor BIGINT,
        ValorAntesMultiplicar INT,
        ValorMultiplicado INT
    );

CREATE TABLE LlamadasOtro (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FechaOperacion DATE,
    DuracionMinutos INT,
    Emisor BIGINT,
    Receptor BIGINT,
    ValorAntesMultiplicar INT,
    ValorMultiplicado INT
);


CREATE TABLE Llamadas900 (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        FechaOperacion DATE,
        DuracionMinutos INT,
        Emisor BIGINT,
        Receptor BIGINT,
        ValorAntesMultiplicar INT,
        ValorMultiplicado INT
    );

