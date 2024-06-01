ALTER PROCEDURE ProcesarLlamadas800
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos de cada llamada
    DECLARE @Id INT;
    DECLARE @NumeroDe BIGINT;
    DECLARE @NumeroA BIGINT;
    DECLARE @Inicio DATETIME;
    DECLARE @Fin DATETIME;
    DECLARE @FechaOperacion DATE;
    DECLARE @DiferenciaMinutos INT;
    DECLARE @ValorTotalLlamada INT;

    -- Variables para almacenar información del contrato y tarifa
    DECLARE @TipoTarifa INT;
    DECLARE @ValorElemento INT;

    -- Cursor para recorrer las filas de la tabla ResultadosLlamadas
    DECLARE curLlamadas CURSOR FOR
    SELECT FechaOperacion, Id, NumeroDe, NumeroA, DiferenciaMinutos
    FROM ResultadosLlamadas;

    OPEN curLlamadas;
    FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si tanto el emisor como el receptor tienen el número que comienza con '800'
        IF LEFT(CAST(@NumeroDe AS VARCHAR(20)), 3) = '800' OR LEFT(CAST(@NumeroA AS VARCHAR(20)), 3) = '800'
        BEGIN
            -- Obtener el contrato asociado con el número 800
            SELECT @TipoTarifa = c.TipoTarifa
            FROM Contratos c
            WHERE c.Numero = CASE WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 3) = '800' THEN @NumeroDe ELSE @NumeroA END;

            -- Obtener el valor del elemento de la tarifa asociada con el tipo de tarifa
            SELECT @ValorElemento = et.Valor
            FROM ElementoDeTipoTarifa et
            WHERE et.idTipoTarifa = @TipoTarifa;

            -- Calcular el valor total de la llamada
            SET @ValorTotalLlamada = @ValorElemento * @DiferenciaMinutos;

            -- Insertar los datos en la tabla Llamadas800
            INSERT INTO Llamadas800 (FechaOperacion, DuracionMinutos, Emisor, Receptor, ValorAntesMultiplicar, ValorMultiplicado)
            VALUES (@FechaOperacion, @DiferenciaMinutos, @NumeroDe, @NumeroA, @ValorElemento, @ValorTotalLlamada);
        END;

        FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;
END;

EXEC ProcesarLlamadas800
SELECT * FROM Llamadas800
