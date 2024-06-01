CREATE PROCEDURE [dbo].[ProcesarLlamadas110]
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
        IF @NumeroA = 110
        BEGIN
            -- Obtener el contrato asociado con el número emisor
            SELECT @TipoTarifa = c.TipoTarifa
            FROM Contratos c
            WHERE c.Numero = @NumeroDe;

            -- Obtener el valor del elemento de la tarifa asociada con el tipo de tarifa
            SELECT @ValorElemento = et.Valor
            FROM ElementoDeTipoTarifa et
            WHERE et.idTipoTarifa = @TipoTarifa;

            -- Calcular el valor total de la llamada
            SET @ValorTotalLlamada = @ValorElemento * @DiferenciaMinutos;

            -- Insertar los datos en la tabla Llamadas911
            INSERT INTO Llamadas110 (FechaOperacion, DuracionMinutos, Emisor, Receptor, ValorAntesMultiplicar, ValorMultiplicado)
            VALUES (@FechaOperacion, @DiferenciaMinutos, @NumeroDe, @NumeroA, @ValorElemento, @ValorTotalLlamada);
        END;

        FETCH NEXT FROM curLlamadas INTO @FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;
END;


EXEC ProcesarLlamadas110
SELECT * FROM Llamadas110