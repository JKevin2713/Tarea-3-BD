USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[InsertarDatosFactura]    Script Date: 15/06/2024 15:45:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- El procedimiento InsertarDatosFactura calcula los montos de pago de una factura, incluyendo excesos de minutos y gigas, así 
-- como cobros adicionales por servicios como llamadas de emergencia. También actualiza los detalles de la factura con los montos calculados antes 
-- y después del IVA, así como las multas pendientes.

--Descripcion de parametros:
 --   @inIdFactura: ID de la factura
 --   @inNumero BIGINT: Número de factura
	--@OutResulTCode: código de resultado de salida

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[InsertarDatosFactura]
    @inIdFactura INT,          -- ID de la factura
    @inNumero BIGINT,          -- Número de factura
	@OutResulTCode INT OUTPUT  -- Código de resultado de salida
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el mensaje "número de filas afectadas" se devuelva como parte del resultado

    BEGIN TRY
        -- Inicialización del código de resultado de salida
        SET @OutResulTCode = 0;
		BEGIN TRANSACTION insertarDatosAFactura;

        -- Declaración de variables locales
        DECLARE @MinExceso INT,
                @GigasExceso DECIMAL(4,2),
                @MinFamilia INT,
                @Cobro911 INT,
                @Cobro110 INT,
                @Cobro900 INT,
                @Cobro800 INT,
                @ValorMin110 INT,
                @ValorMin900 INT,
                @ValorMin800 INT,
                @IVA DECIMAL(4,2),
				@PagoAntesIva INT,
				@Multa DECIMAL(18,2);

        -- Obtener valores fijos

		SELECT @Cobro911 = MCC.Costo911
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		SELECT @ValorMin110 = MCC.Costo110
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

        SELECT @ValorMin800 = ETT.Valor
        FROM [dbo].[ElementoDeTipoTarifa] ETT
        WHERE idTipoElemento = 9;

        SELECT @ValorMin900 = ETT.Valor
        FROM [dbo].[ElementoDeTipoTarifa] ETT
        WHERE idTipoElemento = 10;

		-----------------------------
		
		SELECT @IVA = MCC.IVA/100.00
        FROM [dbo].[MontoCobroContrato] MCC
        WHERE MCC.IdNumero = @inNumero;

		-- Obtener valores de la factura y detalles
		SELECT @PagoAntesIva = TarifaBasica
		FROM [dbo].[DetalleElementoCobro]
		WHERE IdFactura = @inIdFactura
		
		SELECT @Multa = MultaFacturaPendiente
		FROM [dbo].[Factura]
		WHERE Id = @inIdFactura

        -- Obtención de minutos y cobros
        SELECT @MinExceso = MinutosBase,
               @MinFamilia = MinutosFamilia,
               @Cobro110 = Minutos110 * @ValorMin110,
               @Cobro900 = Minutos900 * @ValorMin900,
               @Cobro800 = Minutos800 * @ValorMin800
        FROM [dbo].[TotalMinutosLlamada]
        WHERE IdFactura = @inIdFactura AND Numero = @inNumero;

        -- Obtención de gigas de exceso
        SELECT @GigasExceso = GigasBase
        FROM [dbo].[TotalGigasUso]
        WHERE IdFactura = @inIdFactura AND Numero = @inNumero;

        -- Actualización de DetalleElementoCobro con los valores obtenidos
        UPDATE DetalleElementoCobro
        SET MinutosLlamadaFamiliar = @MinFamilia,
            Cobro911 = @Cobro911,
            Cobro110 = @Cobro110,
            Cobro900 = @Cobro900,
            Cobro800 = @Cobro800
        WHERE IdFactura = @inIdFactura;

        -- Lógica para exceso de minutos y gigas
        IF @MinExceso >= 0 AND  @GigasExceso < 0
		BEGIN 
			UPDATE DetalleElementoCobro
			SET MinutosExceso = @MinExceso
			WHERE IdFactura = @inIdFactura;
		END
		ELSE IF @MinExceso < 0 AND  @GigasExceso >= 0
		BEGIN 
			UPDATE DetalleElementoCobro
			SET GigasExceso = @GigasExceso
			WHERE IdFactura = @inIdFactura;
		END
		ELSE IF @MinExceso >= 0 AND  @GigasExceso >= 0
		BEGIN 
			UPDATE DetalleElementoCobro
			SET MinutosExceso = @MinExceso,
				GigasExceso = @GigasExceso
			WHERE IdFactura = @inIdFactura;
		END
        ELSE
        BEGIN 
            SET @MinExceso = 0;
            SET @GigasExceso = 0;

            UPDATE DetalleElementoCobro
            SET MinutosExceso = @MinExceso,
                GigasExceso = @GigasExceso
            WHERE IdFactura = @inIdFactura;
        END

		-- Cálculo de pagos antes e después de IVA
		SET @PagoAntesIva = @PagoAntesIva + @MinExceso + @GigasExceso + @Cobro911 + @Cobro110 + @Cobro900 + @Cobro800;

		-- Actualización de la factura con los pagos y multas calculados
		UPDATE Factura
        SET TotalPagoAntesIva = @PagoAntesIva,
            TotalPagoDespuesIva = (@PagoAntesIva * @IVA) + @PagoAntesIva,
            TotalPagoMulta = (((@PagoAntesIva * @IVA) + @PagoAntesIva) + @Multa)
        WHERE Id = @inIdFactura;

        -- Confirmar la transacción
        COMMIT TRANSACTION; 

        -- Devolver un mensaje de éxito
        SELECT @OutResulTCode AS OutResultCode;
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
        SELECT @OutResultCode AS OutResultCode;
    END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;

GO


