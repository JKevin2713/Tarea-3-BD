CREATE PROCEDURE RestarHorasLlamadas
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

    -- Cursor para recorrer las filas de la tabla LlamadaTelefonica
    DECLARE curLlamadas CURSOR FOR
    SELECT Id, NumeroDe, NumeroA, Inicio, Fin, FechaOperacion
    FROM LlamadaTelefonica;

    -- Variables para almacenar las horas en formato de tiempo
    DECLARE @HoraInicio TIME;
    DECLARE @HoraFin TIME;

    -- Variable para almacenar la diferencia de tiempo en minutos
    DECLARE @DiferenciaMinutos INT;

    OPEN curLlamadas;
    FETCH NEXT FROM curLlamadas INTO @Id, @NumeroDe, @NumeroA, @Inicio, @Fin, @FechaOperacion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Convertir las horas de inicio y fin a formato de tiempo
        SET @HoraInicio = CONVERT(TIME, @Inicio);
        SET @HoraFin = CONVERT(TIME, @Fin);

        -- Calcular la diferencia de tiempo en minutos
        SET @DiferenciaMinutos = DATEDIFF(MINUTE, @HoraInicio, @HoraFin);

        -- Insertar los resultados en la tabla de resultados
        INSERT INTO ResultadosLlamadas (FechaOperacion, Id, NumeroDe, NumeroA, DiferenciaMinutos)
        VALUES (@FechaOperacion, @Id, @NumeroDe, @NumeroA, @DiferenciaMinutos);

        FETCH NEXT FROM curLlamadas INTO @Id, @NumeroDe, @NumeroA, @Inicio, @Fin, @FechaOperacion;
    END;

    CLOSE curLlamadas;
    DEALLOCATE curLlamadas;


END;

EXEC RestarHorasLlamadas
SELECT * FROM ResultadosLLamadas