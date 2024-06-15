USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ValidarFechaPago]    Script Date: 15/06/2024 15:48:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--El procedimiento valida fechas de pago de facturas, aplica multas si es necesario, y realiza acciones adicionales según la fecha de operación.

--Descripcion de parametros:
    -- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ValidarFechaPago]
    @InFechaOperacion DATE,
	@OutResulTCode INT OUTPUT -- Código de resultado de salida

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Id INT,
            @IdNumero BIGINT,
            @TotalPagoAntesIva INT,
            @TotalPagoDespuesIva INT,
            @MultaFacturaPendiente INT,
            @TotalPagoMulta INT,
            @FechaPagoFactura DATE,
            @FechaDiaGraciaPago DATE,
            @FacturaPagada BIT,
            @Multa INT

    DECLARE @TotalRegistros INT
    DECLARE @Contador INT = 1


    BEGIN TRY
		 -- Inicialización
			SET @OutResulTCode = 0;
			BEGIN TRANSACTION validarFechaPagoFactura

			-- Crear una tabla temporal para almacenar las facturas
			CREATE TABLE #TempFacturas (
				RowNum INT IDENTITY(1, 1),
				Id INT,
				IdNumero BIGINT,
				TotalPagoAntesIva INT,
				TotalPagoDespuesIva INT,
				MultaFacturaPendiente INT,
				TotalPagoMulta INT,
				FechaPagoFactura DATE,
				FechaDiaGraciaPago DATE,
				FacturaPagada BIT
			)

			-- Insertar las facturas en la tabla temporal
			INSERT INTO #TempFacturas (Id, IdNumero, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente, TotalPagoMulta, FechaPagoFactura, FechaDiaGraciaPago, FacturaPagada)
			SELECT Id, IdNumero, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente, TotalPagoMulta, FechaPagoFactura, FechaDiaGraciaPago, FacturaPagada
			FROM Factura
			WHERE FacturaPagada = 0;

			-- Obtener el número total de registros
			SET @TotalRegistros = (SELECT COUNT(*) FROM #TempFacturas)

			-- Iterar sobre cada factura
			WHILE @Contador <= @TotalRegistros
			BEGIN
				-- Obtener los datos de la factura actual
				SELECT 
					@Id = Id, 
					@IdNumero = IdNumero,
					@TotalPagoAntesIva = TotalPagoAntesIva,
					@TotalPagoDespuesIva = TotalPagoDespuesIva,
					@MultaFacturaPendiente = MultaFacturaPendiente,
					@TotalPagoMulta = TotalPagoMulta,
					@FechaPagoFactura = FechaPagoFactura,
					@FechaDiaGraciaPago = FechaDiaGraciaPago,
					@FacturaPagada = FacturaPagada
				FROM #TempFacturas
				WHERE RowNum = @Contador

				-- Verificar si la fecha está fuera del margen de fechas para la factura actual
				IF @inFechaOperacion > @FechaDiaGraciaPago
				BEGIN
					SELECT @Multa = MCC.MultaPagoAtrasado
					FROM [dbo].[MontoCobroContrato] MCC
					WHERE MCC.IdNumero = @IdNumero;


					UPDATE [dbo].[Factura]
					SET MultaFacturaPendiente = @Multa
					WHERE id = @Id AND IdNumero = @IdNumero AND FacturaPagada = 0;

					-- Llamar a los procedimientos almacenados necesarios
					EXEC [dbo].[InsertarDatosFactura] @InIdFactura = @ID, @InNumero = @IdNumero, @OutResulTCode = 0;
				END

				IF @FechaPagoFactura = @inFechaOperacion
				BEGIN
					EXEC [dbo].[InsertarDatosFactura] @InIdFactura = @ID, @InNumero = @IdNumero, @OutResulTCode = 0;
					EXEC [dbo].[crearFactura] @InNumero = @IdNumero, @InFechaOperacion = @InFechaOperacion, @OutResulTCode = 0;

				END
				-- Incrementar el contador
				SET @Contador = @Contador + 1
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


