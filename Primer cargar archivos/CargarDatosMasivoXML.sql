--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- Realiza la lectura del XMl, el cual se encuentra almacenado en una de las computadoras
-- el cual se lee y se mapea a las tablas segun corresponde

--------------------------------------------------------------------
--SELECT *FROM Facturas

--SELECT COUNT(*) AS TotalVeces
--FROM Facturas
--WHERE IdContrato= 19;

CREATE PROCEDURE [dbo].[XMLInsertarDatosMasivos]
    @xml AS XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION InsertarDatosMasivosXML

        DECLARE @xQuery AS XML = @xml;

		----------ITERACIONES 
        -- Se crea una tabla temporal que guarda todos los dias de operacion
        DECLARE @TemporalFechas TABLE 
        (
            FechaOperacion DATE
        );

        INSERT INTO @TemporalFechas (FechaOperacion)
        SELECT CONVERT(DATE, x.value('@fecha', 'VARCHAR(10)')) AS FechaOperacion
        FROM @xQuery.nodes('/Operaciones/FechaOperacion') AS TempXML(x);

		--Se declara la fecha maxima y la minima para lograr identificar las fechas 
        DECLARE @maximo DATE, @actual DATE;
        SELECT @maximo = MAX(FechaOperacion), @actual = MIN(FechaOperacion) FROM @TemporalFechas;

        --Se compran las dos fechas para identificarlas en el orden correcto 
        WHILE (@actual <= @maximo)
        BEGIN 

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
            INSERT INTO [dbo].[Contratos] (DocIdCliente, TipoTarifa, Numero, FechaOperacion)
            SELECT
                [dbo].[Clientes].Identificacion AS DocIdCliente,
                [dbo].[TiposTarifa].Id AS TipoTarifa,
                x.value('@Numero', 'BIGINT') AS Numero,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/NuevoContrato') AS TempXML (x)
            LEFT JOIN [dbo].[Clientes] ON x.value('@DocIdCliente', 'INT') = [dbo].[Clientes].Identificacion
            LEFT JOIN [dbo].[TiposTarifa] ON x.value('@TipoTarifa', 'INT') = [dbo].[TiposTarifa].Id;

	

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


		---------------------------------------------------------------------------
            -- Insertamos datos en la tabla PagoFactura
            INSERT INTO [dbo].[PagoFactura] (Numero, FechaOperacion)
            SELECT
                [dbo].[Contratos].Numero AS Numero,
                @actual AS FechaOperacion
            FROM @xQuery.nodes('/Operaciones/FechaOperacion[@fecha = sql:variable("@actual")]/PagoFactura') AS TempXML (x)
            LEFT JOIN [dbo].[Contratos] ON x.value('@Numero', 'BIGINT') = [dbo].[Contratos].Numero;

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
		---------------------------------------------------------------------------
			EXEC [dbo].[ProcesarLlamadasEmpresaX] @actual;

            -- Actualizamos @actual para pasar a la siguiente iteración
            SET @actual = DATEADD(DAY, 1, @actual); -- Incrementamos la fecha actual en un día
        END;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
