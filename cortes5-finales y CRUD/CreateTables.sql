CREATE TABLE DBError (
    Id INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único para cada error
    UserName NVARCHAR(128),            -- Nombre del usuario que ejecutó la operación
    ErrorNumber INT,                   -- Número del error
    ErrorState INT,                    -- Estado del error
    ErrorSeverity INT,                 -- Gravedad del error
    ErrorLine INT,                     -- Línea donde ocurrió el error
    ErrorProcedure NVARCHAR(128),      -- Procedimiento donde ocurrió el error
    ErrorMessage NVARCHAR(4000),       -- Mensaje del error
    ErrorDate DATETIME                 -- Fecha y hora del error
);


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

CREATE TABLE ValorTipoElementoFijo (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    Valor INT,
    IdTipoElemento INT FOREIGN KEY REFERENCES TiposElemento(Id)
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
    NumeroDe BIGINT,        
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

CREATE TABLE ResultadosLlamadasTOTALES (
    FechaOperacion DATE,
    Id INT,
    NumeroDe BIGINT,
    NumeroA BIGINT,
    DiferenciaMinutos INT,
    ValorAntesMultiplicar INT,
    ValorMultiplicado INT,
);



CREATE TABLE Facturas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdContrato INT FOREIGN KEY REFERENCES Contratos(Id),
    TotalPagoAntesIva DECIMAL(18, 2),
    TotalPagoDespuesIva DECIMAL(18, 2),
    MultaFacturaPendiente  DECIMAL(18, 2),
    TotalPagar DECIMAL(18, 2),
    FechaFactura DATE,
    FechaPago DATE,
    EstaPagada BIT
);





CREATE TABLE LlamadasX (
    FechaCorte DATE,  
	FechaLlamada DATE,
    Inicio TIME(0),
    Fin TIME(0),
    Duracion INT,
    NumeroDe BIGINT,
    NumeroA BIGINT,
    TipoLlamada NVARCHAR(10)
);

CREATE TABLE LlamadasY (
    FechaCorte DATE, 
	FechaLlamada DATE,
    Inicio TIME(0),
    Fin TIME(0),
    Duracion INT,
    NumeroDe BIGINT,
    NumeroA BIGINT,
    TipoLlamada NVARCHAR(10)
);



















