USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[XMLInsertarDatosMasivos]    Script Date: 15/06/2024 15:50:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- Realiza la lectura del XMl, el cual se encuentra almacenado en una de las computadoras
-- el cual se lee y se mapea a las tablas segun corresponde

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[XMLInsertarDatosMasivos]
    @xml AS XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION InsertarDatosMasivosXML

        DECLARE @xQuery AS XML = @xml;
		DECLARE @outResultCode INT;


        INSERT INTO [dbo].[Fechas] 
		(
			FechaOperacion
		)
        SELECT 
			x.value('@fecha', 'DATE') AS FechaOperacion

        FROM @xQuery.nodes('/Operaciones/FechaOperacion') AS TempXML(x);

		--Se declara la fecha maxima y la minima para lograr identificar las fechas 
        DECLARE 
			@maximo DATE
		  , @actual DATE;

        SELECT @maximo = MAX(FechaOperacion), @actual = MIN(FechaOperacion) FROM [dbo].[Fechas];

        --Se compran las dos fechas para identificarlas en el orden correcto 
        WHILE (@actual <= @maximo)
        BEGIN 

			EXEC [dbo].[ValidarFechaPago] @InFechaOperacion = @actual, @OutResulTCode = 0;
        ---------------------------------------------------------------------------
			-- Insertar datos de Clientes
            INSERT INTO [dbo].[Clientes] (Identificacion, Nombre, FechaOperacion)
            SELECT
                x.value('@Identificacion', 'INT') AS Identificacion,
                x.value('@Nombre', 'VARCHAR(255)') AS Nombre,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/ClienteNuevo') AS TempXML (x);

        ---------------------------------------------------------------------------
            -- Insertamos datos en la tabla Contratos
            INSERT INTO [dbo].[Contratos] (DocIdCliente, TipoTarifa, Numero, FechaOperacion, Activo)
            SELECT
                [dbo].[Clientes].Identificacion AS DocIdCliente,
                [dbo].[TiposTarifa].Id AS TipoTarifa,
                x.value('@Numero', 'BIGINT') AS Numero,
                @actual AS FechaOperacion,
				0
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/NuevoContrato') AS TempXML (x)
            LEFT JOIN [dbo].[Clientes] ON x.value('@DocIdCliente', 'INT') = [dbo].[Clientes].Identificacion
            LEFT JOIN [dbo].[TiposTarifa] ON x.value('@TipoTarifa', 'INT') = [dbo].[TiposTarifa].Id;

			EXEC [dbo].[agregarDetallesDeCobro] @InFechaOperacion = @actual,  @outResultCode = 0
			EXEC [dbo].[agregarFactura] @InFechaOperacion = @actual, @InCrearFactura = 0,  @outResultCode = 0;

		---------------------------------------------------------------------------
            -- Insertamos datos en la tabla LlamadaTelefonica
            INSERT INTO [dbo].[LlamadaTelefonica] (NumeroDe, NumeroA, Inicio, Fin, FechaOperacion)
            SELECT
				x.value('@NumeroDe', 'BIGINT') AS NumeroDe,
                x.value('@NumeroA', 'BIGINT') AS NumeroA,
                CONVERT(DATETIME, x.value('@Inicio', 'NVARCHAR(30)'), 120) AS Inicio,
                CONVERT(DATETIME, x.value('@Final', 'NVARCHAR(30)'), 120) AS Fin,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/LlamadaTelefonica') AS TempXML (x)

			EXEC [dbo].[ProcesarLlamadas] @InFechaOperacion = @actual,  @outResultCode = 0;

		---------------------------------------------------------------------------
            -- Insertamos datos en la tabla PagoFactura
            INSERT INTO [dbo].[PagoFactura] (Numero, FechaOperacion)
            SELECT
                [dbo].[Contratos].Numero AS Numero,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/PagoFactura') AS TempXML (x)
            LEFT JOIN [dbo].[Contratos] ON x.value('@Numero', 'BIGINT') = [dbo].[Contratos].Numero;

			-- Validar si hay pagos en la fecha específica
			IF EXISTS (SELECT 1 FROM [dbo].[PagoFactura] WHERE FechaOperacion = @actual)
			BEGIN
				-- Si hay pagos, ejecutar el procedimiento agregarFactura
				EXEC [dbo].[agregarFactura]  @InFechaOperacion = @actual, @InCrearFactura = 1,  @outResultCode = 0;
			END;

		---------------------------------------------------------------------------
            -- Insertamos datos en la tabla RelacionFamiliar
            INSERT INTO [dbo].[RelacionFamiliar] (DocIdDe, idTipoRelacion, DocIdA, FechaOperacion)
            SELECT
                [dbo].[Clientes].Identificacion AS DocIdDe,
                [dbo].[TipoRelacionesFamiliares].Id AS idTipoRelacion,
                x.value('@DocIdA', 'INT') AS DocIdA,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/RelacionFamiliar') AS TempXML (x)
            LEFT JOIN [dbo].[Clientes] ON x.value('@DocIdDe', 'INT') = [dbo].[Clientes].Identificacion
            LEFT JOIN [dbo].[TipoRelacionesFamiliares] ON x.value('@TipoRelacion', 'INT') = [dbo].[TipoRelacionesFamiliares].Id;

		---------------------------------------------------------------------------
            -- Insertamos datos en la tabla UsoDatos
            INSERT INTO [dbo].[UsoDatos] (NumeroContrato, QGigas, FechaOperacion)
            SELECT
                [dbo].[Contratos].Numero AS NumeroContrato,
                x.value('@QGigas', 'DECIMAL(4,2)') AS QGigas,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/UsoDatos') AS TempXML (x)
            LEFT JOIN [dbo].[Contratos] ON x.value('@Numero', 'BIGINT') = [dbo].[Contratos].Numero;

			EXEC [dbo].[ProcesarGigas] @inFechaOperacion = @actual , @outResultCode = 0;
		---------------------------------------------------------------------------

			EXEC [dbo].[ProcesarLlamadasEmpresaX] @InFechaOperacion = @actual,  @outResultCode = 0;
			EXEC [dbo].[ProcesarLlamadasEmpresaY] @InFechaOperacion = @actual,  @outResultCode = 0;

            -- Actualizamos @actual para pasar a la siguiente iteración
            SET @actual = DATEADD(DAY, 1, @actual); -- Incrementamos la fecha actual en un día
        END;

		EXEC [dbo].[GenerarResumenLlamadasX]  @outResultCode = 0;
		EXEC [dbo].[GenerarResumenLlamadasY]  @outResultCode = 0;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
		
		-- Registrar el error
		INSERT INTO DBError (
			UserName,
			ErrorNumber,
			ErrorState,
			ErrorSeverity,
			ErrorLine,
			ErrorProcedure,
			ErrorMessage,
			ErrorDate
		) 
		VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);
	END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;






GO


