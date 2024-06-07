SELECT COUNT(*) AS Contratos
FROM [EJEMPLO].[dbo].[Contratos]

SELECT COUNT(*) AS LlamadaTelefonica
FROM [lolo].[dbo].[LlamadaTelefonica]

SELECT COUNT(*) AS Clientes 
FROM [Tarea 4].[dbo].[Clientes]
SELECT COUNT(*)

SELECT COUNT(*) AS ResultadosLlamadasTOTALES
FROM [EJEMPLO].[dbo].[ResultadosLlamadasTOTALES]

SELECT COUNT(*) AS LlamadaTelefonica
FROM [EJEMPLO].[dbo].[LlamadaTelefonica]
--------------------------

SELECT * FROM dbo.TiposUnidades
SELECT * FROM dbo.ElementoDeTipoTarifa
SELECT * FROM dbo.TipoRelacionesFamiliares
SELECT * FROM dbo.TiposTarifa
SELECT * FROM dbo.TiposElemento
SELECT *FROM ValorTipoElementoFijo


DROP TABLE dbo.TiposElemento
DROP TABLE dbo.TiposUnidades
DROP TABLE dbo.ElementoDeTipoTarifa
DROP TABLE dbo.TipoRelacionesFamiliares
DROP TABLE dbo.TiposTarifa

-----------------------------------
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Contratos
SELECT * FROM dbo.LlamadasX
SELECT * FROM dbo.PagoFactura
SELECT * FROM dbo.RelacionFamiliar
SELECT * FROM dbo.UsoDatos
SELECT * FROM dbo.Facturas 

DROP TABLE dbo.Clientes
DROP TABLE dbo.Contratos
DROP TABLE dbo.LlamadaTelefonica
DROP TABLE dbo.PagoFactura
DROP TABLE dbo.RelacionFamiliar
DROP TABLE dbo.UsoDatos
DROP TABLE dbo.ResultadosLlamadas
DROP TABLE dbo.Llamadas800
DROP TABLE dbo.Llamadas900
DROP TABLE dbo.Llamadas911
DROP TABLE ResultadosLlamadasTOTALES