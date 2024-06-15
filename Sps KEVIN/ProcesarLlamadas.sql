USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ProcesarLlamadas]    Script Date: 15/06/2024 15:47:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento procesa las llamadas telefonicas para una fecha específica, abre una transacción ,luego, crea una tabla temporal 
-- para almacenar los registros de llamadas telefónicas para la fecha dada. Después, itera sobre estos registros, calculando y actualizando 
-- los minutos correspondientes en la tabla TotalMinutosLlamada para cada número de contrato involucrado en la llamada. 
-- Si ocurre un error durante el proceso, se revierte la transacción, se registra el error en la tabla DBError y se establece el código de 
-- resultado de salida en 50008. Finalmente, se desactiva la supresión del recuento de filas afectadas.

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ProcesarLlamadas]
    @InFechaOperacion DATE, --Fecha de operacion
	@OutResulTCode INT OUTPUT -- Código de resultado de salida

AS
BEGIN
    BEGIN TRY
	   -- Inicialización
        SET @OutResulTCode = 0;

        BEGIN TRANSACTION transicionLlamadas;

        DECLARE @NumeroDe BIGINT,
                @NumeroA BIGINT,
                @Inicio DATETIME,
                @Fin DATETIME,
                @MinutosTotales INT,
                @MinutosAdicionales INT,
                @MinutosNoche INT,
                @MinutosDia INT,
                @MinutosFamilizar INT,
                @Minutos911 INT,
                @Minutos110 INT,
                @Minutos900 INT,
                @Minutos800 INT,
                @id INT,
				@DocIdDe BIGINT,
                @DocIdA BIGINT,
				@Bandera BIT;

        DECLARE @llamadas TABLE (
            NumeroDe BIGINT,           
            NumeroA BIGINT,
            Inicio DATETIME,
            Fin DATETIME,
            FechaOperacion DATE
        );

        INSERT INTO @llamadas (
            NumeroDe,
            NumeroA,
            Inicio,
            Fin,
            FechaOperacion
        )
        SELECT
            L.NumeroDe,
            L.NumeroA,
            L.Inicio,
            L.Fin,
            L.FechaOperacion
        FROM [dbo].[LlamadaTelefonica] L
        WHERE L.FechaOperacion = @inFechaOperacion;

        WHILE EXISTS (SELECT 1 FROM @llamadas)
        BEGIN
            SELECT TOP 1 
                @NumeroDe = NumeroDe,
                @NumeroA = NumeroA,
                @Inicio = Inicio,
                @Fin = Fin
            FROM @llamadas;

            SELECT @id = MAX(Id)
            FROM TotalMinutosLlamada
            WHERE Numero = @NumeroDe;

            SET @MinutosFamilizar = 0;
            SET @Minutos911 = 0;
            SET @Minutos110 = 0;
            SET @Minutos900 = 0;
            SET @Minutos800 = 0;

            IF EXISTS (SELECT 1 FROM TotalMinutosLlamada WHERE Numero = @NumeroDe)
            BEGIN
                SELECT @MinutosTotales = TotalMinutos + DATEDIFF(minute, @Inicio, @Fin),
					   @MinutosAdicionales = MinutosBase + DATEDIFF(minute, @Inicio, @Fin)
                FROM TotalMinutosLlamada
                WHERE Numero = @NumeroDe AND Id = @id;

				SELECT @Bandera = Bandera
				FROM TotalMinutosLlamada
				WHERE Numero = @NumeroDe AND Id = @id;

				SELECT @DocIdDe = DocIdCliente
				FROM Contratos
				WHERE Numero = @NumeroDe;

				SELECT @DocIdA = DocIdCliente
				FROM Contratos
				WHERE Numero = @NumeroA;

				IF EXISTS (
					SELECT 1
					FROM RelacionFamiliar RF
					WHERE (RF.DocIdDe = @DocIdDe AND RF.DocIdA = @DocIdA)
				)
                BEGIN
                    SET @MinutosFamilizar = DATEDIFF(minute, @Inicio, @Fin);
                END;

                IF @NumeroA = 911
                BEGIN
                    SET @Minutos911 = DATEDIFF(minute, @Inicio, @Fin);
                END;

                IF @NumeroA = 110
                BEGIN
                    SET @Minutos110 = DATEDIFF(minute, @Inicio, @Fin);
                END;

                IF LEFT(@NumeroA, 3) = '900'
                BEGIN
                    SET @Minutos900 = DATEDIFF(minute, @Inicio, @Fin);
                END;

                IF LEFT(@NumeroA, 3) = '800'
                BEGIN
                    SET @NumeroDe = @NumeroA;
                END;

                IF LEFT(@NumeroDe, 3) = '800' 
                BEGIN
                    SET @Minutos800 = DATEDIFF(minute, @Inicio, @Fin);
                END;

                UPDATE TotalMinutosLlamada
                SET MinutosFamilia = ISNULL(MinutosFamilia, 0) + @MinutosFamilizar,
                    Minutos911 = ISNULL(Minutos911, 0) + @Minutos911,
                    Minutos110 = ISNULL(Minutos110, 0) + @Minutos110,
                    Minutos900 = ISNULL(Minutos900, 0) + @Minutos900,
                    Minutos800 = ISNULL(Minutos800, 0) + @Minutos800
                WHERE Numero = @NumeroDe AND Id = @id;

                IF @MinutosAdicionales < 0
                BEGIN
                    UPDATE TotalMinutosLlamada
                    SET TotalMinutos = @MinutosTotales,
                        MinutosBase = @MinutosAdicionales
                    WHERE Numero = @NumeroDe AND Id = @id;
                END
                ELSE
                BEGIN
                    IF DATEPART(hour, @Fin) >= 23 OR DATEPART(hour, @Fin) < 5
                    BEGIN
						
                        SELECT @MinutosNoche = ISNULL(MinutosNoche, 0) + DATEDIFF(minute, @Inicio, @Fin)
                        FROM TotalMinutosLlamada
                        WHERE Numero = @NumeroDe AND Id = @id;

						IF @Bandera = 0
						BEGIN
							SET @MinutosNoche = @MinutosAdicionales
						END

                        UPDATE TotalMinutosLlamada
                        SET TotalMinutos = @MinutosTotales,
                            MinutosBase = @MinutosAdicionales,
                            MinutosNoche = @MinutosNoche,
							Bandera = 1
                        WHERE Numero = @NumeroDe AND Id = @id;
                    END
                    ELSE
                    BEGIN
                        SELECT @MinutosDia = ISNULL(MinutosDia, 0) + DATEDIFF(minute, @Inicio, @Fin)
                        FROM TotalMinutosLlamada
                        WHERE Numero = @NumeroDe AND Id = @id;

						IF @Bandera = 0
						BEGIN
							SET @MinutosDia = @MinutosAdicionales
						END

                        UPDATE TotalMinutosLlamada
                        SET TotalMinutos = @MinutosTotales,
                            MinutosBase = @MinutosAdicionales,
                            MinutosDia = @MinutosDia,
							Bandera = 1
                        WHERE Numero = @NumeroDe AND Id = @id;
                    END;
                END;
            END;

            DELETE TOP (1) FROM @llamadas;
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


