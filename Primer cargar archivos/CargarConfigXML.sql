--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- Realiza la lectura del XMl, el cual se encuentra almacenado en una de las computadoras
-- el cual se lee y se mapea a las tablas segun corresponde
--------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[XMLInsertarDatosConfiguracion]
		@xml AS XML
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION InsertarDatosXML

		DECLARE @xQuery AS XML = (SELECT CAST(@xml AS XML))
	---------------------------------------------------------------------------
		--Insertar datos de TiposTarifa
		INSERT INTO [dbo].[TiposTarifa]
		(
		  Id
		, Nombre
		)

		SELECT
		  x.value('@Id', 'INT') 
		, x.value('@Nombre', 'VARCHAR(255)')
		FROM @xQuery.nodes('/Data/TiposTarifa/TipoTarifa') AS TempXML(x)

	---------------------------------------------------------------------------
		-- Insertar datos de TiposElemento
		INSERT INTO [dbo].[TiposElemento]
		(
		  Id
		, Nombre
		)
		SELECT
		  x.value('@Id', 'INT') 
		, x.value('@Nombre', 'VARCHAR(255)')
		FROM @xQuery.nodes('/Data/TiposElemento/TipoElemento') AS TempXML (x)

	---------------------------------------------------------------------------
		-- Insertar datos de TiposMovimientos
		INSERT INTO [dbo].[TiposUnidades]
		(
		  Id
		, Tipo
		)
		SELECT
		  x.value('@Id', 'INT') 
		, x.value('@Tipo', 'NVARCHAR(255)') 
		FROM @xQuery.nodes('/Data/TiposUnidades/TipoUnidad') AS TempXML (x)

	-------------------------------------------------------------------------
		-- Insertar datos de Elementosfijos
		INSERT INTO [dbo].[ElementosFijos]
		(
		  idTipoUnidad
		, Id
		, Nombre
		, Valor
		)
		SELECT
		 [dbo].[TiposUnidades].Id
		, x.value('@Id', 'INT') 
		, x.value('@Nombre', 'VARCHAR(255)')
		, x.value('@Valor', 'INT')
		FROM @xQuery.nodes('/Data/ElementosFijos/ElementoFijo') AS TempXML (x)
		LEFT JOIN [dbo].[TiposUnidades] on x.value('@IdTipoUnidad','INT') = [dbo].[TiposUnidades].Id

	---------------------------------------------------------------------------
		-- Insertar datos de ElementoDeTipoTarifa
		INSERT INTO [dbo].[ElementoDeTipoTarifa]
		  (
			idTipoTarifa
		  , IdTipoElemento
		  , IdTipoUnidad
		  , Valor
		  )
		  SELECT
		    [dbo].[TiposTarifa].Id
		  , [dbo].[TiposElemento].Id
		  , [dbo].[TiposUnidades].Id
		  , x.value('@Valor', 'INT')
  
		  FROM @xQuery.nodes('/Data/ElementosDeTipoTarifa/ElementoDeTipoTarifa') AS TempXML (x)
		  LEFT JOIN [dbo].[TiposTarifa] on x.value('@idTipoTarifa','INT') = [dbo].[TiposTarifa].Id
		  LEFT JOIN [dbo].[TiposElemento] on x.value('@IdTipoElemento','INT') = [dbo].[TiposElemento].Id
		  LEFT JOIN [dbo].[TiposUnidades] on x.value('@IdTipoUnidad','INT') = [dbo].[TiposUnidades].Id

	-------------------------------------------------------------------------
		-- Insertar datos de TipoRelacionesFamiliares
		INSERT INTO [dbo].[TipoRelacionesFamiliares]
		(
		  Id
		, Nombre
		)
		SELECT
		  x.value('@Id', 'INT')
		, x.value('@Nombre', 'VARCHAR(255)')
		FROM @xQuery.nodes('/Data/TipoRelacionesFamiliar/TipoRelacionFamiliar') AS TempXML (x)

	-------------------------------------------------------------------------
	COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        SELECT ERROR_MESSAGE() AS ErrorMessage
    END CATCH

END

