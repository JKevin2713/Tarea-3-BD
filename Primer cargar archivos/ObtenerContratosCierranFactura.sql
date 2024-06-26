CREATE PROCEDURE [dbo].[ObtenerContratosCierranFactura]
    @fechaOperacion DATE
AS
BEGIN
    -- Tabla temporal para almacenar los contratos que cierran facturas
    CREATE TABLE #ContratosCierranFactura (
        IDContrato INT,
        TotalPagoAntesIva DECIMAL(18, 2),
        TotalPagoDespuesIva DECIMAL(18, 2),
        MultaFacturaPendiente DECIMAL(18, 2),
        TotalPagar DECIMAL(18, 2),
        Estado VARCHAR(50) -- Agrega el estado del contrato
    );

    -- Insertar los contratos que cierran facturas según la fecha de operación
    INSERT INTO #ContratosCierranFactura (IDContrato, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente, TotalPagar, Estado)
    SELECT
        C.Id,
        -- Aquí puedes calcular los valores necesarios para TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente, TotalPagar
        0, -- Ejemplo de valor para TotalPagoAntesIva
        0, -- Ejemplo de valor para TotalPagoDespuesIva
        0, -- Ejemplo de valor para MultaFacturaPendiente
        0, -- Ejemplo de valor para TotalPagar
        'Cerrado' -- Aquí defines el estado como 'Cerrado' para los contratos que cierran factura
    FROM
        Contratos C
    WHERE
        C.FechaOperacion <= DATEADD(MONTH, -1, @fechaOperacion) AND 
        NOT EXISTS (
            SELECT 1
            FROM Facturas F
            WHERE F.IdContrato = C.Id
                AND F.FechaFactura > DATEADD(MONTH, -1, @fechaOperacion)
        );

    -- Devolver los resultados
    SELECT * FROM #ContratosCierranFactura;

    -- Eliminar la tabla temporal
    DROP TABLE #ContratosCierranFactura;
END;
GO
