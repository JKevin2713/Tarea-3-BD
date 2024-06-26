
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IngresarDatosPrimerosClientes]
    @fechaOperacion DATE
AS
BEGIN
    -- Ingresar los datos de los clientes ingresados en la fecha especificada
    INSERT INTO [dbo].[PrimerosClientes] (Identificacion, FechaOperacion, ProximaFechaPago)
    SELECT  DocIdCliente, @fechaOperacion, DATEADD(MONTH, 1, @fechaOperacion)
    FROM [dbo].[Contratos]
    WHERE FechaOperacion = @fechaOperacion;
END;
