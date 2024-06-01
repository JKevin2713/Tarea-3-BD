USE [Tarea3]
GO

/****** Object:  StoredProcedure [dbo].[agregarFactura]    Script Date: 31/05/2024 19:27:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[agregarFactura]
    @InFechaOperacion DATE,
    @InCrearFactura BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION InsertarFactura;

        DECLARE @TarifaBase INT,
                @Numero BIGINT,
                @TipoTarifa INT;

        -- Obtener contratos para los cuales aún no se ha generado factura
        -- Supongamos que hay un campo en la tabla Contratos que indica si se ha facturado o no
        -- Supongamos que ese campo se llama Facturado y es de tipo bit
        DECLARE @Contratos TABLE (
            Numero BIGINT
        );
		IF @InCrearFactura = 0
			BEGIN
				INSERT INTO @Contratos (Numero)
				SELECT c.Numero
				FROM [dbo].[Contratos] c
				WHERE c.FechaOperacion = @InFechaOperacion;
			END

			ELSE IF @InCrearFactura = 1
			BEGIN
				INSERT INTO @Contratos (Numero)
				SELECT PF.Numero
				FROM [dbo].[PagoFactura] PF
				WHERE PF.FechaOperacion = @InFechaOperacion;
			END;



        -- Iterar sobre los contratos no facturados
			WHILE EXISTS (SELECT 1 FROM @Contratos)
			BEGIN
				-- Obtener el siguiente contrato no facturado
				SELECT TOP 1 @Numero = Numero
				FROM @Contratos;

				IF @InCrearFactura = 0
				BEGIN
					-- Llamar al procedimiento para crear una nueva factura
					EXEC [dbo].[crearFactura] @InNumero = @Numero, @InFechaOperacion = @InFechaOperacion;
				END
				ELSE IF @InCrearFactura = 1
				BEGIN
					-- Llamar al procedimiento para procesar un pago de factura
					EXEC [dbo].[procesarPagoFactura] @InNumero = @Numero, @InFechaOperacion = @InFechaOperacion;
				END;

				-- Eliminar el contrato procesado de la tabla temporal
				DELETE FROM @Contratos WHERE Numero = @Numero;

			END;

        COMMIT TRANSACTION; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;

GO


