USE [Tarea3]
GO

/****** Object:  StoredProcedure [dbo].[procesarPagoFactura]    Script Date: 31/05/2024 19:27:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[procesarPagoFactura]
    @InNumero BIGINT,
    @InFechaOperacion DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION PagoFactura;

        -- Actualizar el estado de la factura a pagada
        UPDATE [dbo].[Factura]
        SET FacturaPagada = 1
        WHERE IdNumero = @InNumero AND FacturaPagada = 0;

        -- Aquí podrías agregar más lógica si es necesario para validar el pago

        -- Llamar al procedimiento para crear una nueva factura
        EXEC [dbo].[crearFactura] @InNumero = @InNumero, @InFechaOperacion = @InFechaOperacion;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO


