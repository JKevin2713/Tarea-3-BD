USE [Tarea3]
GO

/****** Object:  StoredProcedure [dbo].[crearFactura]    Script Date: 31/05/2024 19:27:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[crearFactura]
    @InNumero BIGINT,
    @InFechaOperacion DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION CrearFactura;

        DECLARE @TarifaBase INT;

        -- Seleccionar la tarifa base según el tipo de contrato
        SELECT @TarifaBase = ETT.Valor
        FROM [dbo].[Contratos] C
        JOIN [dbo].[ElementoDeTipoTarifa] ETT ON C.TipoTarifa = ETT.idTipoTarifa 
            AND ETT.idTipoElemento = CASE
                WHEN LEFT(CAST(@InNumero AS VARCHAR(20)), 3) = '800' THEN 9
                WHEN LEFT(CAST(@InNumero AS VARCHAR(20)), 3) = '900' THEN 10
                ELSE 1
            END
        WHERE C.Numero = @InNumero;

        -- Insertar la nueva factura
        INSERT INTO [dbo].[Factura] (
            IdNumero,
            TotalPagoAntesIva,
            TotalPagoDespuesIva,
            MultaFacturaPendiente,
            TotalPagoMulta,
			FechaCreacionFactura,
            FechaPagoFactura,
            FacturaPagada
        )
        VALUES (
            @InNumero, 
            0, 
            0, 
            0, 
            0, 
			@InFechaOperacion,
            DATEADD(MONTH, 1, @InFechaOperacion),
            0
        );

        DECLARE @IdFactura INT = SCOPE_IDENTITY();

        -- Inserción en la tabla DetalleElementoCobro
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

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO


