USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ProcesarGigas]    Script Date: 15/06/2024 15:46:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento procesa los datos de uso de gigas para una fecha específica. Luego, crea una tabla temporal para almacenar 
-- los registros de uso de gigas para la fecha dada. Después, itera sobre estos registros, calculando y actualizando los gigas totales 
-- y adicionales para cada contrato en la tabla TotalGigasUso. Si ocurre un error durante el proceso, se revierte la transacción, 
-- se registra el error en la tabla DBError y se establece el código de resultado de salida en 50008. Finalmente, se desactiva la supresión 
-- del recuento de filas afectadas.

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ProcesarGigas]
    @inFechaOperacion DATE, --Fecha de operacion
	@OutResulTCode INT OUTPUT -- Código de resultado de salida

AS
BEGIN
	SET NOCOUNT ON; -- Evita que el mensaje "número de filas afectadas" se devuelva como parte del resultado
    BEGIN TRY
	    -- Inicialización
        SET @OutResulTCode = 0;
        BEGIN TRANSACTION transicionGigas;

        DECLARE @Numero BIGINT,
				@Gigas DECIMAL(4,2),
				@GigasTotales DECIMAL(4,2),
				@GigasAdicionales DECIMAL(4,2),
				@id INT;

        DECLARE @usoGigas TABLE (
            Numero BIGINT,           
			QGigas  DECIMAL(4,2),
			FechaOperacion DATE
        );

			INSERT INTO @usoGigas (
			Numero,
			QGigas,
			FechaOperacion
			)
			SELECT
			G.NumeroContrato,
			G.QGigas,
			G.FechaOperacion
			FROM [dbo].[UsoDatos] G
			WHERE G.FechaOperacion = @inFechaOperacion;


        -- Iterar sobre los contratos no facturados
			WHILE EXISTS (SELECT 1 FROM @usoGigas)
			BEGIN

				SELECT TOP 1 
					@Numero = Numero,
					@Gigas = QGigas
				FROM @usoGigas;

			    SELECT @id = MAX(Id)
				FROM TotalGigasUso
				WHERE Numero = @Numero;

				
				IF EXISTS (SELECT 1 FROM TotalGigasUso WHERE Numero = @Numero)
				BEGIN
					
					SELECT @GigasTotales = @Gigas + TotalGigas
					FROM TotalGigasUso
					WHERE Numero = @Numero AND Id = @id;

					SELECT @GigasAdicionales = @Gigas + GigasBase
					FROM TotalGigasUso
					WHERE Numero = @Numero AND Id = @id;

					UPDATE TotalGigasUso
					SET TotalGigas = @GigasTotales,
						GigasBase = @GigasAdicionales
					WHERE Numero = @Numero AND Id = @id;

				END;

				DELETE TOP (1) FROM @usoGigas;

			END;

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

		-- Establecer el código de resultado de salida en error
		SET @OutResultCode = 50008;
		SELECT @OutResulTCode AS OutResultCode;
	END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;


GO


