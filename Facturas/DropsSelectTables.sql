USE Tarea3

SELECT COUNT(*) AS Contratos
FROM [Tarea3].[dbo].[Contratos]

SELECT COUNT(*) AS Clientes 
FROM [Tarea3].[dbo].[Clientes]
--------------------------


SELECT * FROM dbo.TiposTarifa
SELECT * FROM dbo.TiposUnidades
SELECT * FROM dbo.TiposElemento
SELECT * FROM dbo.ValorTipoElementoFijo
SELECT * FROM dbo.ElementoDeTipoTarifa
SELECT * FROM dbo.TipoRelacionesFamiliares


DROP TABLE dbo.TiposTarifa
DROP TABLE dbo.TiposUnidades
DROP TABLE dbo.TiposElemento
DROP TABLE dbo.ValorTipoElementoFijo
DROP TABLE dbo.ElementoDeTipoTarifa
DROP TABLE dbo.TipoRelacionesFamiliares

-----------------------------------

SELECT * FROM dbo.Fechas
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Contratos
SELECT * FROM dbo.LlamadaTelefonica
SELECT * FROM dbo.PagoFactura
SELECT * FROM dbo.RelacionFamiliar
SELECT * FROM dbo.UsoDatos


DELETE FROM Fechas;
DELETE FROM Clientes;
DELETE FROM Contratos;
DELETE FROM LlamadaTelefonica;
DELETE FROM PagoFactura;
DELETE FROM RelacionFamiliar;
DELETE FROM UsoDatos;



DROP TABLE dbo.Fechas
DROP TABLE dbo.Clientes;
DROP TABLE dbo.Contratos
DROP TABLE dbo.LlamadaTelefonica
DROP TABLE dbo.PagoFactura
DROP TABLE dbo.RelacionFamiliar
DROP TABLE dbo.UsoDatos
--------------------
DROP TABLE dbo.Factura
DROP TABLE dbo.DetalleElementoCobro

SELECT * FROM dbo.Factura
SELECT * FROM dbo.DetalleElementoCobro



-------------------
SELECT * FROM dbo.ResultadosLlamadas
SELECT * FROM dbo.Llamadas800
SELECT * FROM dbo.LlamadasOtro
SELECT * FROM dbo.Llamadas900


DROP TABLE dbo.ResultadosLlamadas
DROP TABLE dbo.Llamadas800
DROP TABLE dbo.LlamadasOtro
DROP TABLE dbo.Llamadas900
