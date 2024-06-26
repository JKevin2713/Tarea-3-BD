USE [Tarea3]
GO

/****** Object:  StoredProcedure [dbo].[XMLInsertarDatosConfiguracion]    Script Date: 31/05/2024 19:28:09 ******/
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
		
		---------------------------------------------------------------------------
		-- Insertar datos de TiposElemento
		INSERT INTO [dbo].[TiposElemento]
		(
		  Id
		, Nombre
		, idTipoUnidad
		, EsFijo
		)
		SELECT
		  x.value('@Id', 'INT') 
		, x.value('@Nombre', 'VARCHAR(255)')
		, [dbo].[TiposUnidades].Id
		, x.value('@EsFijo', 'BIT')
		FROM @xQuery.nodes('/Data/TiposElemento/TipoElemento') AS TempXML (x)
		LEFT JOIN [dbo].[TiposUnidades] on x.value('@IdTipoUnidad','INT') = [dbo].[TiposUnidades].Id

		---------------------------------------------------------------------------
		-- Insertar datos de valor de ValorTipoElementoFijo
		INSERT INTO [dbo].[ValorTipoElementoFijo]
		(
		  Valor
		, IdTipoElemento
		)
		SELECT
		  x.value('@Valor', 'INT') 
		, [dbo].[TiposElemento].Id

		FROM @xQuery.nodes('/Data/TiposElemento/TipoElemento') AS TempXML (x)
		LEFT JOIN [dbo].[TiposElemento] on x.value('@Id','INT') = [dbo].[TiposElemento].Id
		WHERE x.value('@EsFijo', 'BIT') = 1;
		
	---------------------------------------------------------------------------
		-- Insertar datos de ElementoDeTipoTarifa
		INSERT INTO [dbo].[ElementoDeTipoTarifa]
		  (
			idTipoTarifa
		  , IdTipoElemento
		  , Valor
		  )
		  SELECT
		    [dbo].[TiposTarifa].Id
		  , [dbo].[TiposElemento].Id
		  , x.value('@Valor', 'INT')
  
		  FROM @xQuery.nodes('/Data/ElementosDeTipoTarifa/ElementoDeTipoTarifa') AS TempXML (x)
		  LEFT JOIN [dbo].[TiposTarifa] on x.value('@idTipoTarifa','INT') = [dbo].[TiposTarifa].Id
		  LEFT JOIN [dbo].[TiposElemento] on x.value('@IdTipoElemento','INT') = [dbo].[TiposElemento].Id

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

GO


