USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[agregarDetallesDeCobro]    Script Date: 15/06/2024 15:40:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado agrega facturas 
-- según el valor del parámetro de entrada `@inCrearFactura`. Itera sobre los contratos no facturados, 
-- llamando a procedimientos específicos para cada contrato y maneja errores en caso de que ocurran.

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
	-- @inCrearFactura: Valo del id para crear la factura
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[agregarDetallesDeCobro]
    @InFechaOperacion DATE,
    @outResultCode INT OUTPUT

AS
BEGIN
    -- Evita que el número de filas afectadas se devuelva como parte del resultado
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicia una transacción llamada InsertarFactura
        BEGIN TRANSACTION InsertarMontos;

        -- Declaración de variables locales
        DECLARE @Numero BIGINT,
				@TarifaBase INT,
                @MinutosBase INT,
				@MinAdicinalRegular INT,
				@MinAdicinalReducido INT,
				@GigasBase INT,
				@GigasAdicionales INT,
				@DiasGraciaPago INT,
				@MultaPagoAtrasado INT,
				@Costo911 INT,
				@IVA INT,
				@Costo110 INT,
				@CostoEmpresaX INT,
				@CostoEmpresaY INT;


        -- Crea una tabla temporal para almacenar los números de contrato
        DECLARE @Contratos TABLE (
            Numero BIGINT
        );

		INSERT INTO @Contratos (Numero)
        SELECT c.Numero
        FROM [dbo].[Contratos] c
        WHERE c.FechaOperacion = @InFechaOperacion;

        -- Itera sobre los contratos no facturados en la tabla temporal
        WHILE EXISTS (SELECT 1 FROM @Contratos)
        BEGIN
            -- Obtiene el siguiente contrato no facturado de la tabla temporal
            SELECT TOP 1 @Numero = Numero
            FROM @Contratos;

			SELECT @TarifaBase = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 1
			WHERE C.Numero = @Numero;
						
		    SELECT @MinutosBase = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				AND ETT.idTipoElemento = 2
			WHERE C.Numero = @Numero;

			SELECT @MinAdicinalRegular = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 3
			WHERE C.Numero = @Numero;

			SELECT @MinAdicinalReducido = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 4
			WHERE C.Numero = @Numero;

			SELECT @GigasBase = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 5
			WHERE C.Numero = @Numero;

			SELECT @GigasAdicionales = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 6
			WHERE C.Numero = @Numero;

			SELECT @DiasGraciaPago = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 7
			WHERE C.Numero = @Numero;

			SELECT @MultaPagoAtrasado = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 8
			WHERE C.Numero = @Numero;

			SELECT @Costo911 = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 11
			WHERE C.Numero = @Numero;

			SELECT @IVA = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 12
			WHERE C.Numero = @Numero;

			SELECT @Costo110 = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 13
			WHERE C.Numero = @Numero;

			SELECT @CostoEmpresaX = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 14
			WHERE C.Numero = @Numero;

			SELECT @CostoEmpresaY = ETT.Valor
			FROM [dbo].[Contratos] C
			JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
				 AND ETT.idTipoElemento = 15
			WHERE C.Numero = @Numero;


			INSERT INTO MontoCobroContrato (
				IdNumero,
				TarifaBase,
				MinutosBase,
				MinAdicinalRegular,
				MinAdicinalReducido,
				GigasBase,
				GigasAdicionales,
				DiasGraciaPago,
				MultaPagoAtrasado,
				Costo911,
				IVA,
				Costo110,
				CostoEmpresaX,
				CostoEmpresaY
			)
            VALUES  (
				 @Numero,
				 @TarifaBase,
				 @MinutosBase,
				 @MinAdicinalRegular,
				 @MinAdicinalReducido,
				 @GigasBase,
				 @GigasAdicionales,
			 	 @DiasGraciaPago,
				 @MultaPagoAtrasado,
				 @Costo911,
				 @IVA,
				 @Costo110,
				 @CostoEmpresaX,
				 @CostoEmpresaY
            );

            -- Elimina el contrato procesado de la tabla temporal
            DELETE FROM @Contratos WHERE Numero = @Numero;
        END;

        -- Establece el código de resultado de salida en éxito
        SET @outResultCode = 0;

        -- Confirma la transacción
        COMMIT TRANSACTION; 

        -- Devuelve el código de resultado de salida
        SELECT @outResultCode AS outResultCode;
    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshace
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 

        -- Registra el error en la tabla DBErrors
        INSERT INTO dbo.DBError (
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

        -- Establece el código de resultado de salida en error
        SET @outResultCode = 50008;

        -- Devuelve el código de resultado de salida
        SELECT @outResultCode AS outResultCode;
    END CATCH;

    -- Restaura el recuento de filas afectadas para las instrucciones SELECT, INSERT, UPDATE y DELETE
    SET NOCOUNT OFF; 
END;
GO


