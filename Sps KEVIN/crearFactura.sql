USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[crearFactura]    Script Date: 15/06/2024 15:44:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento crea una nueva factura con detalles específicos. Calcula valores basados en el tipo de contrato, 
--inserta la factura y sus detalles en las tablas correspondientes, y maneja errores registrándolos en una tabla designada.
--Descripcion de parametros:
    -- @inNumero: Numero a buscar 
	-- @inFechaOperacion: Fecha de operacion
    -- @OutResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[crearFactura]
    @inNumero BIGINT,
    @inFechaOperacion DATE,
    @OutResulTCode INT OUTPUT      -- Código de resultado de salida
AS
BEGIN
    BEGIN TRY
        -- Inicia una transacción para asegurar la integridad de los datos
        BEGIN TRANSACTION CrearFactura;

        -- Variables para almacenar valores de tarifa y otros datos
        DECLARE @TarifaBase INT,
				@DiasGraciaPago INT,
				@MesPago DATE,
				@MinutosBase INT,
				@GigasBase INT;

        -- Calcula el mes siguiente para la fecha de pago de la factura
		SET @MesPago = DATEADD(MONTH, 1, @inFechaOperacion);

        -- Selecciona la tarifa base y otros valores relacionados según el tipo de contrato
        SELECT @TarifaBase = MCC.TarifaBase
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		-- Selecciona los días de gracia para el pago según el tipo de contrato

		SELECT @DiasGraciaPago = MCC.DiasGraciaPago
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		-- Selecciona los minutos base según el tipo de contrato
		SELECT @MinutosBase = MCC.MinutosBase
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		-- Selecciona los gigas base según el tipo de contrato

		SELECT @GigasBase = MCC.GigasBase
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		-- Si el número de factura comienza con '800' o '900', establece valores específicos a cero
		IF LEFT(@inNumero, 3) = '800' OR LEFT(@inNumero, 3) = '900' 
		BEGIN 
			SET @MinutosBase = 0;
			SET @GigasBase = 0;
			SET @DiasGraciaPago = 0;
			SET @TarifaBase = 0;
		END 

        -- Inserta la nueva factura en la tabla de facturas
        INSERT INTO [dbo].[Factura] (
            IdNumero,
            TotalPagoAntesIva,
            TotalPagoDespuesIva,
            MultaFacturaPendiente,
            TotalPagoMulta,
			FechaPagoFactura,
            FechaDiaGraciaPago,
            FacturaPagada
        )
        VALUES (
            @inNumero, 
            0, 
            0, 
            0, 
            0, 
			@MesPago,
            DATEADD(DAY, @DiasGraciaPago, @MesPago),
            0
        );

        -- Obtiene el ID de la factura recién insertada
        DECLARE @IdFactura INT = SCOPE_IDENTITY();

        -- Inserta los detalles de la factura en la tabla DetalleElementoCobro
        INSERT INTO [dbo].[DetalleElementoCobro] (
            IdFactura,
            TarifaBasica,
            MinutosExceso,
            GigasExceso,
            MinutosLlamadaFamiliar,
            Cobro911,
            Cobro110,
            Cobro900,
            Cobro800
        )
        VALUES (
            @IdFactura,
            @TarifaBase,
            0, -- Valor por defecto para otros campos
            0,
            0,
            0,
            0,
            0,
            0
        );

		-- Inserta los detalles de los minutos de llamada en la tabla TotalMinutosLlamada
		INSERT INTO [dbo].[TotalMinutosLlamada] (
			IdFactura,
			Numero,
			TotalMinutos,
			MinutosBase,
			MinutosNoche,
			MinutosDia,
			MinutosFamilia,
			Minutos110,
			Minutos911,
			Minutos900,
			Minutos800,
			Bandera
		) 
		VALUES (
			@IdFactura,
			@InNumero,
			0,
			@MinutosBase*-1,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		);

		-- Inserta los detalles del uso de gigas en la tabla TotalGigasUso
		INSERT INTO TotalGigasUso (
			IdFactura,
			Numero,
			TotalGigas,
			GigasBase
		) 
		VALUES (
			@IdFactura,
			@InNumero,
			0,
			@GigasBase*-1
		);

        COMMIT TRANSACTION; 
		  -- Devuelve un mensaje de éxito
        SELECT @outResultCode AS outResultCode;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
		
		-- Registra el error en la tabla DBError
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

		-- Establece el código de resultado de salida en error
		SET @OutResultCode = 50008;
		SELECT @OutResulTCode AS OutResultCode;
	END CATCH;
    SET NOCOUNT OFF; -- Restaura el conteo de filas afectadas
END;

GO


