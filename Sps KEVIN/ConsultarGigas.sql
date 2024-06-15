USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ConsultarGigas]    Script Date: 15/06/2024 15:43:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento busca los detalles de una factura en la tabla Factura seg�n el n�mero de factura proporcionado 
-- y maneja los errores que puedan ocurrir durante el proceso.

--Descripcion de parametros:
    -- @inNumeroBuscar: Numero a buscar 
    -- @OutResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose d�a por d�a 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ConsultarGigas]
    @InNumero BIGINT,
    @InFechaCorte DATE,      -- Par�metro de b�squeda
    @OutResulTCode INT OUTPUT   -- C�digo de resultado de salida
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el mensaje "n�mero de filas afectadas" se devuelva como parte del resultado

    BEGIN TRY
			
			SET @OutResulTCode = 0;

			IF @InNumero  IS NOT NULL AND @InFechaCorte IS NOT NULL
			BEGIN 
				DECLARE @Fechainicio DATE;
				DECLARE @FechaFin DATE;

				-- Obtener la FechaOperacion del contrato espec�fico
				SELECT 
					@Fechainicio = FechaOperacion
				FROM 
					Contratos
				WHERE 
					Numero = @InNumero;

				-- Calcular el inicio del mes anterior a @FechaCorte
				SET @Fechainicio = DATEADD(MONTH, DATEDIFF(MONTH, 0, @InFechaCorte), 0);
				SET @Fechainicio = DATEADD(DAY, -1, @Fechainicio);

				-- Ajustar @Fechainicio al primer d�a del mes anterior a la FechaCorte
				SET @Fechainicio = DATEADD(MONTH, -1, @InFechaCorte);
				SET @Fechainicio = DATEADD(DAY, 1 - DAY(@Fechainicio), @Fechainicio);

				-- Calcular la fecha final como el �ltimo d�a del mes anterior a la FechaCorte
				SET @FechaFin = DATEADD(DAY, -1, @InFechaCorte);

				-- Seleccionar las llamadas que ocurrieron dentro del rango deseado
				 SELECT 
					UD.Id,
					UD.NumeroContrato,
					UD.QGigas,
					UD.FechaOperacion
				FROM 
					UsoDatos UD
				WHERE   UD.FechaOperacion >= @Fechainicio
					AND UD.FechaOperacion <= @FechaFin
				ORDER BY 
					UD.FechaOperacion ASC;
			END

			ELSE
			BEGIN
				-- Establece el c�digo de resultado de salida en caso de que el par�metro de b�squeda sea nulo
				SET @OutResulTCode = 50002;
			END;

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

        -- Establecer el c�digo de resultado de salida en error
        SET @OutResultCode = 50008;
        SELECT @OutResultCode AS OutResultCode;
    END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;
GO


