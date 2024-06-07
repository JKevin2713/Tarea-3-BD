--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Procesa las llamadas de la empresa Y, o sea las llamadas que empiezan con el número 7, esto para lograr saber el corte los 5 de cada
-- mes sobre la empresa Y 

--Descripcion de parametros:
	-- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ProcesarLlamadasEmpresaY]
    @inFechaOperacion DATE,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- DECLARAR VARIABLES 
        DECLARE @Inicio DATETIME;
        DECLARE @Fin DATETIME;
        DECLARE @NumeroDe BIGINT;
        DECLARE @NumeroA BIGINT;
        DECLARE @CantidadMinutos INT;
        DECLARE @TipoLlamada NVARCHAR(10);
        DECLARE @Corte DATE;

        -- Se crea un cursor para recorrer las filas de la tabla LlamadaTelefonica
        DECLARE curLlamadas CURSOR FOR
        SELECT Inicio, Fin, NumeroDe, NumeroA, DATEDIFF(MINUTE, Inicio, Fin) AS CantidadMinutos
        FROM LlamadaTelefonica
        WHERE CONVERT(DATE, Inicio) = @inFechaOperacion
        AND (LEFT(CAST(NumeroDe AS VARCHAR(20)), 1) = '6' OR LEFT(CAST(NumeroA AS VARCHAR(20)), 1) = '6');

        OPEN curLlamadas;
        FETCH NEXT FROM curLlamadas INTO @Inicio, @Fin, @NumeroDe, @NumeroA, @CantidadMinutos;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Calcular la fecha de corte para la llamada actual
            IF DATEPART(DAY, @Inicio) >= 5 -- Verificar si la fecha de inicio es el día 5 o después
                SET @Corte = DATEADD(MONTH, 1, DATEADD(DAY, 4, DATEADD(MONTH, DATEDIFF(MONTH, 0, @Inicio), 0)));
            ELSE
                SET @Corte = DATEADD(DAY, 4, DATEADD(MONTH, DATEDIFF(MONTH, 0, @Inicio), 0));

            -- Determinar el tipo de llamada
            SET @TipoLlamada = CASE 
                WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 1) = '6' THEN 'Saliente'
                WHEN LEFT(CAST(@NumeroA AS VARCHAR(20)), 1) = '6' THEN 'Entrante'
                ELSE 'Desconocido'
            END;

            -- Insertar el registro en la tabla LlamadasX
            INSERT INTO LlamadasY (
                Corte,
                Inicio,
                Fin,
                NumeroDe,
                NumeroA,
                CantidadMinutos,
                TipoLlamada
            )
            VALUES (
                @Corte,
                @Inicio,
                @Fin,
                @NumeroDe,
                @NumeroA,
                @CantidadMinutos,
                @TipoLlamada
            );

            FETCH NEXT FROM curLlamadas INTO @Inicio, @Fin, @NumeroDe, @NumeroA, @CantidadMinutos;
        END;

        CLOSE curLlamadas;
        DEALLOCATE curLlamadas;

        -- Establecer el código de resultado de salida en éxito
        SET @outResultCode = 0;
        SELECT @outResultCode AS outResultCode;
    END TRY
    BEGIN CATCH
        -- Manejo de errores
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
