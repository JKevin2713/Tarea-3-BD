ALTER PROCEDURE [dbo].[ProcesarLlamadas911]
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos de cada llamada
    DECLARE @Id INT;
    DECLARE @NumeroDe BIGINT;
    DECLARE @NumeroA BIGINT;
    DECLARE @FechaOperacion DATE;
    DECLARE @DiferenciaMinutos INT;
    DECLARE @ValorTotalLlamada INT;

    -- Variables para almacenar información del contrato y tarifa
    DECLARE @TipoTarifa INT;
    DECLARE @ValorElemento INT;

    -- Cursor para recorrer las filas únicas de la tabla ResultadosLlamadas
    DECLARE curLlamadas CURSOR FOR
    SELECT DISTINCT FechaOperacion, Id, NumeroDe, NumeroA, DiferenciaMinutos
    FROM ResultadosLlamadas;

    OPEN curLlamadas;
    FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el número receptor es el "911"
        IF @NumeroA = 911
        BEGIN
            -- Obtener el contrato asociado con el número emisor
            SELECT @TipoTarifa = c.TipoTarifa
            FROM Contratos c
            WHERE c.Numero = @NumeroDe;

            -- Obtener el valor del elemento de la tarifa asociada con el tipo de tarifa
            SELECT @ValorElemento = Valor
            FROM ValorTipoElementoFijo
            WHERE Id = 1; -- Obtener el valor del ID 1

            -- Insertar los datos en la tabla Llamadas911
            INSERT INTO Llamadas911 (FechaOperacion, DuracionMinutos, Emisor, Receptor, )
            VALUES (@FechaOperacion, @DiferenciaMinutos, @NumeroDe, @NumeroA, @ValorElemento);
        END;

        FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;
END;


EXEC ProcesarLlamadas911
SELECT * FROM Llamadas911

SELECT * FROM  ValorTipoElementoFijo