--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- Carga el archivo XML

--------------------------------------------------------------------
DECLARE @XML AS XML
DECLARE @id AS INT

-- Cargar el archivo XML en una variable XML
SELECT @XML = Contenido.DatosXML
FROM OPENROWSET(BULK 'C:\Users\Usuario\Downloads\datos\config.xml', SINGLE_BLOB) AS Contenido(DatosXML) 

-- Crear un identificador de documento XML
--EXEC sp_xml_preparedocument @id OUTPUT, @XML


--NOTA: en usuarios cambien los & por ;
EXEC [dbo].[XMLInsertarDatosConfiguracion] @xml = @XML