USE Tarea3

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
    Id IDENTITY (1, 1) PRIMARY KEY,
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


------------
CREATE TABLE  Factura (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdNumero BIGINT FOREIGN KEY REFERENCES Contratos(Numero),
	TotalPagoAntesIva INT,
	TotalPagoDespuesIva INT,
	MultaFacturaPendiente INT,
	TotalPagoMulta INT,
	FechaCreacionFactura DATE,
	FechaPagoFactura DATE,
	FacturaPagada BIT
);

CREATE TABLE  DetalleElementoCobro (
    Id INT IDENTITY (1, 1) PRIMARY KEY,
	IdFactura INT FOREIGN KEY REFERENCES Factura(Id),
	TarifaBasica INT,
	MinutosExceso INT,
	GigasExceso INT,
	MinutosLlamadaFamiliar INT,
	Cobro911 INT,
	Cobro110 INT,
	Cobro900 INT,
	Cobro800 INT
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

