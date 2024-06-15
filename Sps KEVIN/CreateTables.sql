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

CREATE TABLE Fechas (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
    FechaOperacion DATE
);

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
	FechaOperacion DATE,
	Activo BIT
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


------------
CREATE TABLE  Factura (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdNumero BIGINT FOREIGN KEY REFERENCES Contratos(Numero),
	TotalPagoAntesIva DECIMAL(18,2),
	TotalPagoDespuesIva DECIMAL(18,2),
	MultaFacturaPendiente DECIMAL(18,2),
	TotalPagoMulta DECIMAL(18,2),
	FechaPagoFactura DATE,
	FechaDiaGraciaPago DATE,
	FacturaPagada BIT
);

CREATE TABLE  DetalleElementoCobro (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdFactura INT FOREIGN KEY REFERENCES Factura(Id),
	TarifaBasica INT,
	MinutosExceso INT,
	GigasExceso DECIMAL(4,2),
	MinutosLlamadaFamiliar INT,
	Cobro911 INT,
	Cobro110 INT,
	Cobro900 INT,
	Cobro800 INT
);


CREATE TABLE MontoCobroContrato (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdNumero BIGINT FOREIGN KEY REFERENCES Contratos(Numero),
	TarifaBase INT,
	MinutosBase INT,
	MinAdicinalRegular INT,
	MinAdicinalReducido INT,
	GigasBase INT,
	GigasAdicionales INT,
	DiasGraciaPago INT,
	MultaPagoAtrasado INT,
	Costo911 INT,
	Min110 INT,
	IVA INT,
	Costo110 INT,
	CostoEmpresaX INT,
	CostoEmpresaY INT

);
---------------


CREATE TABLE TotalMinutosLlamada (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdFactura INT FOREIGN KEY REFERENCES Factura(Id),
    Numero BIGINT,
    TotalMinutos INT,
	MinutosBase INT,
	MinutosNoche INT,
	MinutosDia INT,
	MinutosFamilia INT,
	Minutos110 INT,
	Minutos911 INT,
	Minutos900 INT,
	Minutos800 INT,
	Bandera BIT

);

CREATE TABLE TotalGigasUso (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdFactura INT FOREIGN KEY REFERENCES Factura(Id),
    Numero BIGINT,
    TotalGigas DECIMAL(4,2),
	GigasBase DECIMAL(4,2)
);


---------------------

CREATE TABLE LlamadasX (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
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
	Id INT IDENTITY (1, 1) PRIMARY KEY,
    FechaCorte DATE, 
	FechaLlamada DATE,
    Inicio TIME(0),
    Fin TIME(0),
    Duracion INT,
    NumeroDe BIGINT,
    NumeroA BIGINT,
    TipoLlamada NVARCHAR(10)
);

CREATE TABLE ResumenLlamadasX (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
    FechaCorte DATE,
    TotalMinutosEntrantes INT,
    TotalMinutosSalientes INT,
    FechaApertura DATETIME,
    FechaCierre DATETIME,
    Estado NVARCHAR(50)
);
CREATE TABLE ResumenLlamadasY (
	Id INT IDENTITY (1, 1) PRIMARY KEY,
    FechaCorte DATE,
    TotalMinutosEntrantes INT,
    TotalMinutosSalientes INT,
    FechaApertura DATETIME,
    FechaCierre DATETIME,
    Estado NVARCHAR(50)
);


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



---------------------------
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

