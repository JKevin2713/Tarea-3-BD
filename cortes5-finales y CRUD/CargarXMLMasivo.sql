--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- Carga el archivo XML de operacionesMasivas


--------------------------------------------------------------------
DECLARE @XML AS XML
DECLARE @id AS INT

-- Cargar el archivo XML en una variable XML
SELECT @XML = Contenido.DatosMasivosXML
FROM OPENROWSET(BULK 'C:/Users/Usuario/Downloads/prueba.xml', SINGLE_BLOB) AS Contenido(DatosMasivosXML) 

-- Crear un identificador de documento XML
--EXEC sp_xml_preparedocument @id OUTPUT, @XML


--NOTA: en usuarios cambien los & por ;
EXEC [dbo].[XMLInsertarDatosMasivos] @xml = @XML