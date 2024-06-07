ALTER PROCEDURE ProcesarLlamadas900
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos de cada llamada
    DECLARE @FechaOperacion DATE;
    DECLARE @Id INT;
    DECLARE @NumeroDe BIGINT;
    DECLARE @NumeroA BIGINT;
    DECLARE @DiferenciaMinutos INT;
    DECLARE @ValorTotalLlamada INT;
    DECLARE @TipoTarifa INT;
    DECLARE @ValorElemento INT;

    -- Cursor para recorrer las filas de la tabla ResultadosLlamadas
    DECLARE curLlamadas CURSOR FOR
    SELECT FechaOperacion, Id, NumeroDe, NumeroA, DiferenciaMinutos
    FROM ResultadosLlamadas
    WHERE LEFT(CAST(NumeroDe AS VARCHAR(20)), 3) = '900';

    OPEN curLlamadas;
    FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el número receptor no es un número 900
        IF LEFT(CAST(@NumeroA AS VARCHAR(20)), 3) <> '900'
        BEGIN
            -- Obtener el contrato asociado con el número 900
            SELECT @TipoTarifa = c.TipoTarifa
            FROM Contratos c
            WHERE c.Numero = @NumeroDe;

            -- Obtener el valor del elemento de la tarifa asociada con el tipo de tarifa
            SELECT @ValorElemento = et.Valor
            FROM ElementoDeTipoTarifa et
            WHERE et.idTipoTarifa = @TipoTarifa;

            -- Calcular el valor total de la llamada
            SET @ValorTotalLlamada = @ValorElemento * @DiferenciaMinutos;

            -- Insertar información de la llamada en la tabla Llamadas900
            INSERT INTO Llamadas900 (FechaOperacion, DuracionMinutos, Emisor, Receptor, ValorAntesMultiplicar, ValorMultiplicado)
            VALUES (@FechaOperacion, @DiferenciaMinutos, @NumeroDe, @NumeroA, @ValorElemento, @ValorTotalLlamada);
        END;

        FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;
END;

EXEC ProcesarLlamadas900
SELECT * FROM Llamadas900


