-- Procedimiento almacenado para agregar factura y cerrar las facturas anteriores
CREATE PROCEDURE [dbo].[agregarFactura]
    @fechaOperacion DATE
AS
BEGIN
    -- Tabla temporal para los contratos que abren factura
    DECLARE @ContratosAbrenFactura TABLE (
        IDContrato INT
    );

    -- Tabla temporal para los contratos que cierran factura
    DECLARE @ContratosCierranFactura TABLE (
        IDContrato INT,
        TotalPagoAntesIva DECIMAL(18, 2),
        TotalPagoDespuesIva DECIMAL(18, 2),
        MultaFacturaPendiente DECIMAL(18, 2),
        TotalPagar DECIMAL(18, 2),
        Estado VARCHAR(50) -- Supongamos que el estado puede ser 'Abierto' o 'Cerrado'
    );

    -- Obtener los contratos que abren factura en la fecha de operación
    INSERT INTO @ContratosAbrenFactura (IDContrato)
    SELECT Id
    FROM Contratos
    WHERE FechaOperacion = @fechaOperacion;

    -- Obtener los contratos que cierran factura en el mismo periodo
    INSERT INTO @ContratosCierranFactura (IDContrato, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente, TotalPagar, Estado)
    EXEC dbo.ObtenerContratosCierranFactura @fechaOperacion;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar el estado de los contratos que cierran factura a 'Cerrado'
        UPDATE @ContratosCierranFactura
        SET Estado = 'Cerrado';

        -- Actualizar las facturas para los contratos que cierran
        UPDATE F
        SET
            TotalPagoAntesIva = CF.TotalPagoAntesIva,
            TotalPagoDespuesIva = CF.TotalPagoDespuesIva,
            MultaFacturaPendiente = CF.MultaFacturaPendiente,
            TotalPagar = CF.TotalPagar
        FROM dbo.Facturas F
        INNER JOIN @ContratosCierranFactura CF ON F.IdContrato = CF.IDContrato;

        -- Insertar nuevas facturas para los contratos que abren
        DECLARE @NuevasFacturas TABLE (
            IDFactura INT,
            IdContrato INT
        );

        -- Insertar las nuevas facturas y actualizar la fecha del contrato
        INSERT INTO dbo.Facturas (
            IdContrato,
            TotalPagoAntesIva,
            TotalPagoDespuesIva,
            MultaFacturaPendiente,
            TotalPagar,
            FechaFactura,
            FechaPago,
            EstaPagada 
        )
        OUTPUT INSERTED.ID, INSERTED.IdContrato INTO @NuevasFacturas(IDFactura, IdContrato)
        SELECT 
            IDContrato,
            0 AS TotalPagoAntesIva,
            0 AS TotalPagoDespuesIva,
            0 AS MultaFacturaPendiente,
            0 AS TotalPagar,
            @fechaOperacion AS FechaFactura,
            DATEADD(MONTH, 1, @fechaOperacion) AS FechaPago,
            0 AS EstaPagada
        FROM @ContratosAbrenFactura;

        -- Actualizar la fecha del contrato para el nuevo mes
        UPDATE Contratos
        SET FechaOperacion = DATEADD(MONTH, 1, @fechaOperacion)
        WHERE Id IN (SELECT IdContrato FROM @NuevasFacturas);

        -- Insertar detalles y registros en la tabla de CobroFijo (supongamos que ya tienes la lógica para esto)

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
