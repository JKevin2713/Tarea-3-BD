USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ProcesarLlamadasEmpresaX]    Script Date: 15/06/2024 15:47:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Procesa las llamadas de la empresa X, o sea las llamadas que empiezan con el n�mero 7, esto para lograr saber el corte los 5 de cada
-- mes sobre la empresa X 

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando d�a por d�a cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla
        -- si el codigo es 0, el codigo se ejecuto correctamente
        -- si es otro valor, se puede consultar en la tabla de errores

-- Notas adicionales:
-- El script se va corriendo iterandose d�a por d�a 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ProcesarLlamadasEmpresaX]
    @inFechaOperacion DATE,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciar la transacci�n
        BEGIN TRANSACTION;

        -- DECLARAR VARIABLES 
        DECLARE @Inicio DATETIME;
        DECLARE @Fin DATETIME;
        DECLARE @NumeroDe BIGINT;
        DECLARE @NumeroA BIGINT;
        DECLARE @CantidadMinutos INT;
        DECLARE @TipoLlamada NVARCHAR(10);
        DECLARE @Corte DATE;
        DECLARE @RowNum INT = 1;
        DECLARE @TotalRows INT;

        -- Obtener el total de filas a procesar
        SELECT @TotalRows = COUNT(*)
        FROM LlamadaTelefonica
        WHERE CONVERT(DATE, Inicio) = @inFechaOperacion
        AND (LEFT(CAST(NumeroDe AS VARCHAR(20)), 1) = '7' OR LEFT(CAST(NumeroA AS VARCHAR(20)), 1) = '7');

        WHILE @RowNum <= @TotalRows
        BEGIN
            -- Obtener los datos de la fila actual
            SELECT 
                @Inicio = Inicio, 
                @Fin = Fin, 
                @NumeroDe = NumeroDe, 
                @NumeroA = NumeroA, 
                @CantidadMinutos = DATEDIFF(MINUTE, Inicio, Fin)
            FROM (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY Inicio) AS RowNum,
                    Inicio, 
                    Fin, 
                    NumeroDe, 
                    NumeroA
                FROM LlamadaTelefonica
                WHERE CONVERT(DATE, Inicio) = @inFechaOperacion
                AND (LEFT(CAST(NumeroDe AS VARCHAR(20)), 1) = '7' OR LEFT(CAST(NumeroA AS VARCHAR(20)), 1) = '7')
            ) AS Llamadas
            WHERE RowNum = @RowNum;

            -- Calcular la fecha de corte para la llamada actual
            IF DATEPART(DAY, @Inicio) >= 5 -- Verificar si la fecha de inicio es el d�a 5 o despu�s
                SET @Corte = DATEADD(MONTH, 1, DATEADD(DAY, 4, DATEADD(MONTH, DATEDIFF(MONTH, 0, @Inicio), 0)));
            ELSE
                SET @Corte = DATEADD(DAY, 4, DATEADD(MONTH, DATEDIFF(MONTH, 0, @Inicio), 0));

            -- Determinar el tipo de llamada
            SET @TipoLlamada = CASE 
                WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 1) = '7' THEN 'Saliente'
                WHEN LEFT(CAST(@NumeroA AS VARCHAR(20)), 1) = '7' THEN 'Entrante'
                ELSE 'Desconocido'
            END;

            -- Insertar el registro en la tabla LlamadasX
            INSERT INTO LlamadasX (
                FechaCorte,
                FechaLlamada,
                Inicio,
                Fin,
                Duracion,
                NumeroDe,
                NumeroA,
                TipoLlamada
            )
            VALUES (
                @Corte,
                CONVERT(DATE, @Inicio),
                CAST(@Inicio AS TIME),
                CAST(@Fin AS TIME),
                @CantidadMinutos,
                @NumeroDe,
                @NumeroA,
                @TipoLlamada
            );

            -- Avanzar a la siguiente fila
            SET @RowNum = @RowNum + 1;
        END;

        -- Confirmar la transacci�n
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Manejo de errores

        -- Revertir la transacci�n si ocurre un error
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

        -- Establecer el c�digo de resultado de salida en error
        SET @outResultCode = 50008;
        SELECT @outResultCode AS outResultCode;
    END CATCH;
END;

GO


