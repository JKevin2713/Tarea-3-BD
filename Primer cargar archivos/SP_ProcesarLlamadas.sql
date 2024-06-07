ALTER PROCEDURE ProcesarLlamadas
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
    DECLARE @ValorAntesMultiplicar INT = 0; -- Valor por defecto cuando no es 800 o 900
    DECLARE @ValorMultiplicado INT = 0; -- Valor por defecto cuando no es 800 o 900

    -- Variables para almacenar información del contrato y tarifa
    DECLARE @TipoTarifa INT;
    DECLARE @ValorElemento INT;

    -- Cursor para recorrer las filas de la tabla LlamadaTelefonica
    DECLARE curLlamadas CURSOR FOR
    SELECT Id, NumeroDe, NumeroA, Inicio, Fin, FechaOperacion
    FROM LlamadaTelefonica;

    OPEN curLlamadas;
    FETCH NEXT FROM curLlamadas INTO @Id, @NumeroDe, @NumeroA, @Inicio, @Fin, @FechaOperacion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Convertir las horas de inicio y fin a formato de tiempo
        SET @DiferenciaMinutos = DATEDIFF(MINUTE, @Inicio, @Fin);

        -- Obtener el contrato asociado con el número
        SELECT TOP 1 @TipoTarifa = c.TipoTarifa
        FROM Contratos c
        WHERE c.Numero = CASE 
                            WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 3) = '900' THEN @NumeroDe 
                            WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 3) = '800' THEN @NumeroDe 
                            WHEN LEFT(CAST(@NumeroA AS VARCHAR(20)), 3) = '800' THEN @NumeroA 
                            WHEN LEFT(CAST(@NumeroDe AS VARCHAR(20)), 1) IN ('6', '7') AND LEFT(CAST(@NumeroA AS VARCHAR(20)), 3) != '800' THEN @NumeroDe
                            ELSE @NumeroA
                          END;

        -- Obtener el valor del elemento de la tarifa asociada con el tipo de tarifa
        SELECT TOP 1 @ValorElemento = et.Valor
        FROM ElementoDeTipoTarifa et
        WHERE et.idTipoTarifa = @TipoTarifa;

        -- Calcular el valor total de la llamada
        SET @ValorAntesMultiplicar = @ValorElemento;
        SET @ValorMultiplicado = @ValorElemento * @DiferenciaMinutos;

        -- Insertar los resultados en la tabla ResultadosLlamadas
        -- Verificar si la llamada ya fue insertada para evitar duplicados
        IF NOT EXISTS (
            SELECT 1 FROM ResultadosLlamadasTOTALES
            WHERE Id = @Id AND FechaOperacion = @FechaOperacion
        )
        BEGIN
            INSERT INTO ResultadosLlamadasTOTALES (FechaOperacion, Id, NumeroDe, NumeroA, DiferenciaMinutos, ValorAntesMultiplicar, ValorMultiplicado)
            VALUES (@FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos, @ValorAntesMultiplicar, @ValorMultiplicado);
        END;

        FETCH NEXT FROM curLlamadas INTO @Id, @NumeroDe, @NumeroA, @Inicio, @Fin, @FechaOperacion;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;
END;


EXEC ProcesarLlamadas;
SELECT * FROM ResultadosLlamadasTOTALES;




