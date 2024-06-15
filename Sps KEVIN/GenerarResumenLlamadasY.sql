USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[GenerarResumenLlamadasY]    Script Date: 15/06/2024 15:45:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Crea el resumen del total de llamadas entrantes y salientes de la empresa Y, segun las llamadas realizadas antes del 5 de cada mes

--Descripcion de parametros:
    -- @outResultCode: resultado del insertado en la tabla
        -- si el codigo es 0, el codigo se ejecuto correctamente
        -- si es otro valor, se puede consultar en la tabla de errores

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[GenerarResumenLlamadasY]
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciar la transacción
        BEGIN TRANSACTION;

        DECLARE @FechaCorte DATE;
        DECLARE @TotalMinutosEntrantes INT;
        DECLARE @TotalMinutosSalientes INT;
        DECLARE @FechaApertura DATE;
        DECLARE @FechaCierre DATE;
        DECLARE @Estado VARCHAR(50);
        DECLARE @ExistenDatosEnElMesSiguiente BIT;
        DECLARE @FechaCorteSiguiente DATE;

        -- Obtener la fecha mínima y máxima de las fechas de corte en LlamadasY
        DECLARE @FechaCorteMin DATE = (SELECT MIN(CAST(FechaCorte AS DATE)) FROM LlamadasY);
        DECLARE @FechaCorteMax DATE = (SELECT MAX(CAST(FechaCorte AS DATE)) FROM LlamadasY);

        SET @FechaCorte = @FechaCorteMin;

        WHILE @FechaCorte <= @FechaCorteMax
        BEGIN
            -- Verificar la fecha del mes siguiente
            SET @FechaCorteSiguiente = DATEADD(MONTH, 1, @FechaCorte);
            SELECT @ExistenDatosEnElMesSiguiente = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
            FROM LlamadasY
            WHERE FechaCorte = @FechaCorteSiguiente;

            -- Calcular el total de minutos entrantes para la fecha de corte actual
            SELECT @TotalMinutosEntrantes = ISNULL(SUM(Duracion), 0)
            FROM LlamadasY
            WHERE FechaCorte = @FechaCorte AND TipoLlamada = 'Entrante';

            -- Calcular el total de minutos salientes para la fecha de corte actual
            SELECT @TotalMinutosSalientes = ISNULL(SUM(Duracion), 0)
            FROM LlamadasY
            WHERE FechaCorte = @FechaCorte AND TipoLlamada = 'Saliente';

            -- La fecha de apertura es la misma que la fecha de corte, sin hora
            SET @FechaApertura = CAST(@FechaCorte AS DATE);

            IF @ExistenDatosEnElMesSiguiente = 1
            BEGIN
                -- La fecha de cierre es un mes después de la fecha de corte, sin hora
                SET @FechaCierre = CAST(DATEADD(MONTH, 1, @FechaCorte) AS DATE);
                SET @Estado = 'Cerrado';
            END
            ELSE
            BEGIN
                -- Si no hay datos en el mes siguiente, actualizar la última fila
                SET @TotalMinutosEntrantes = 0;
                SET @TotalMinutosSalientes = 0;
                SET @FechaCierre = CAST(DATEADD(MONTH, 1, @FechaCorte) AS DATE);
                SET @Estado = 'En proceso';

                -- Actualizar la última fila existente a 'En proceso' y con valores en cero
                UPDATE ResumenLlamadasY
                SET Estado = 'En proceso',
                    TotalMinutosEntrantes = 0,
                    TotalMinutosSalientes = 0
                WHERE FechaCorte = (SELECT MAX(FechaCorte) FROM ResumenLlamadasY);
            END

            -- Insertar el resumen en la tabla ResumenLlamadasY
            INSERT INTO ResumenLlamadasY (
                FechaCorte,
                TotalMinutosEntrantes,
                TotalMinutosSalientes,
                FechaApertura,
                FechaCierre,
                Estado
            )
            VALUES (
                @FechaCorte,
                @TotalMinutosEntrantes,
                @TotalMinutosSalientes,
                @FechaApertura,
                @FechaCierre,
                @Estado
            );

            -- Avanzar a la siguiente fecha de corte
            SET @FechaCorte = DATEADD(MONTH, 1, @FechaCorte);
        END;

        -- Eliminar la última fila existente
        DELETE FROM ResumenLlamadasY
        WHERE FechaCorte = (SELECT MAX(FechaCorte) FROM ResumenLlamadasY);

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Manejo de errores

        -- Revertir la transacción si ocurre un error
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

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

        -- Establecer el código de resultado de salida en error
        SET @outResultCode = 50008;
        SELECT @outResultCode AS outResultCode;
    END CATCH;
END;
GO


