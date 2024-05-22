SELECT COUNT(*) AS Contratos
FROM [Tarea 4].[dbo].[Contratos]

SELECT COUNT(*) AS Clientes 
FROM [Tarea 4].[dbo].[Clientes]
--------------------------

SELECT * FROM dbo.TiposUnidades
SELECT * FROM dbo.ElementoDeTipoTarifa
SELECT * FROM dbo.TipoRelacionesFamiliares
SELECT * FROM dbo.TiposTarifa
SELECT * FROM dbo.TiposElemento

DROP TABLE dbo.TiposElemento
DROP TABLE dbo.TiposUnidades
DROP TABLE dbo.ElementoDeTipoTarifa
DROP TABLE dbo.TipoRelacionesFamiliares
DROP TABLE dbo.TiposTarifa

-----------------------------------

SELECT * FROM dbo.FechaOperacion
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Contratos
SELECT * FROM dbo.LlamadaTelefonica
SELECT * FROM dbo.PagoFactura
SELECT * FROM dbo.RelacionFamiliar
SELECT * FROM dbo.UsoDatos


DROP TABLE dbo.FechaOperacion
DROP TABLE dbo.Clientes
DROP TABLE dbo.Contratos
DROP TABLE dbo.LlamadaTelefonica
DROP TABLE dbo.PagoFactura
DROP TABLE dbo.RelacionFamiliar
DROP TABLE dbo.UsoDatos
