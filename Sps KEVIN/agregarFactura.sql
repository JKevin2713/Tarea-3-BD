USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[agregarFactura]    Script Date: 15/06/2024 15:40:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado agrega facturas 
-- seg�n el valor del par�metro de entrada `@inCrearFactura`. Itera sobre los contratos no facturados, 
-- llamando a procedimientos espec�ficos para cada contrato y maneja errores en caso de que ocurran.

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando d�a por d�a cuando se insertan los datos masivos
	-- @inCrearFactura: Valo del id para crear la factura
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose d�a por d�a 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[agregarFactura]
    @InFechaOperacion DATE,
    @InCrearFactura BIT,
    @outResultCode INT OUTPUT

AS
BEGIN
    -- Evita que el n�mero de filas afectadas se devuelva como parte del resultado
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicia una transacci�n llamada InsertarFactura
        BEGIN TRANSACTION InsertarFactura;

        -- Declaraci�n de variables locales
        DECLARE @TarifaBase INT,
                @Numero BIGINT,
                @TipoTarifa INT;

        -- Crea una tabla temporal para almacenar los n�meros de contrato
        DECLARE @Contratos TABLE (
            Numero BIGINT
        );

        -- Inserta n�meros de contrato en la tabla temporal dependiendo del valor de inCrearFactura
        IF @InCrearFactura = 0
        BEGIN
            INSERT INTO @Contratos (Numero)
            SELECT c.Numero
            FROM [dbo].[Contratos] c
            WHERE c.FechaOperacion = @inFechaOperacion;
        END
        ELSE IF @InCrearFactura = 1
        BEGIN
            INSERT INTO @Contratos (Numero)
            SELECT PF.Numero
            FROM [dbo].[PagoFactura] PF
            WHERE PF.FechaOperacion = @inFechaOperacion;
        END;

        -- Itera sobre los contratos no facturados en la tabla temporal
        WHILE EXISTS (SELECT 1 FROM @Contratos)
        BEGIN
            -- Obtiene el siguiente contrato no facturado de la tabla temporal
            SELECT TOP 1 @Numero = Numero
            FROM @Contratos;

            -- Llama al procedimiento correspondiente dependiendo del valor de inCrearFactura
            IF @inCrearFactura = 0
            BEGIN
                -- Llama al procedimiento para crear una nueva factura
                EXEC [dbo].[crearFactura] @InNumero = @Numero, @InFechaOperacion = @inFechaOperacion, @OutResulTCode = 0;
            END
            ELSE IF @inCrearFactura = 1
            BEGIN
                -- Llama al procedimiento para procesar un pago de factura
                EXEC [dbo].[procesarPagoFactura] @InNumero = @Numero, @inFechaOperacion = @inFechaOperacion, @OutResulTCode = 0;
            END;

            -- Elimina el contrato procesado de la tabla temporal
            DELETE FROM @Contratos WHERE Numero = @Numero;
        END;

        -- Establece el c�digo de resultado de salida en �xito
        SET @outResultCode = 0;

        -- Confirma la transacci�n
        COMMIT TRANSACTION; 

        -- Devuelve el c�digo de resultado de salida
        SELECT @outResultCode AS outResultCode;
    END TRY
    BEGIN CATCH
        -- Si hay una transacci�n activa, la deshace
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

        -- Establece el c�digo de resultado de salida en error
        SET @outResultCode = 50008;

        -- Devuelve el c�digo de resultado de salida
        SELECT @outResultCode AS outResultCode;
    END CATCH;

    -- Restaura el recuento de filas afectadas para las instrucciones SELECT, INSERT, UPDATE y DELETE
    SET NOCOUNT OFF; 
END;
GO


