ALTER PROCEDURE dbo.SPUpdateContrato
    @inContratoId INT, -- Parámetro de entrada: identificador del contrato a modificar
    @inNumeroContrato BIGINT, -- Parámetro de entrada: nuevo número de contrato
    @inDocIdCliente INT, -- Parámetro de entrada: nuevo documento de identidad del cliente
    @inTipoTarifa INT, -- Parámetro de entrada: nuevo tipo de tarifa
    @outResultCode INT OUTPUT -- Parámetro de salida: código de resultado de la ejecución
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el número de filas afectadas se devuelva como parte del resultado
    BEGIN TRY
        -- Inicialización del código de resultado
        SET @outResultCode = 0;

        -- Validar que el número de contrato comienza con 8 o 9
        IF LEFT(CAST(@inNumeroContrato AS VARCHAR), 1) NOT IN ('8', '9')
        BEGIN
            SET @outResultCode = 50008; -- Código de error: Número de contrato no válido
            RETURN;
        END;

        -- Validar si el contrato existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Contratos WHERE Id = @inContratoId)
        BEGIN
            SET @outResultCode = 50012; -- Código de error: Contrato no existe
            RETURN;
        END;

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE Identificacion = @inDocIdCliente)
        BEGIN
            SET @outResultCode = 50009; -- Código de error: Cliente no existe
            RETURN;
        END;

        -- Validar si el tipo de tarifa existe
        IF NOT EXISTS (SELECT 1 FROM dbo.TiposTarifa WHERE Id = @inTipoTarifa)
        BEGIN
            SET @outResultCode = 50011; -- Código de error: Tipo de tarifa no válido
            RETURN;
        END;

        -- Actualizar el contrato
        UPDATE Contratos
        SET 
            Numero = @inNumeroContrato,
            DocIdCliente = @inDocIdCliente,
            TipoTarifa = @inTipoTarifa
        WHERE Id = @inContratoId;

        SET @outResultCode = 0; -- Éxito
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50010; -- Código de error genérico

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO DBError (
            UserName,
            ErrorNumber,
            ErrorState,
            ErrorSeverity,
            ErrorLine,
            ErrorProcedure,
            ErrorMessage,
            ErrorDate
        ) 
        VALUES (
            SUSER_SNAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );
    END CATCH;
    SET NOCOUNT OFF;
END;



--SELECT * FROM Contratos
--DECLARE @outResultCode INT;
--EXEC dbo.SPUpdateContrato 
--    @inContratoId = 208, -- Reemplaza 1 con el ID del contrato que deseas modificar
--    @inNumeroContrato = 877888, -- Reemplaza con el nuevo número de contrato
--    @inDocIdCliente = 999999, -- Reemplaza con el nuevo documento de identidad del cliente
--    @inTipoTarifa = 3, -- Reemplaza con el nuevo tipo de tarifa
--    @outResultCode = @outResultCode OUTPUT;
--SELECT @outResultCode AS ResultCode;
