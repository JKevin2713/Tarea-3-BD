ALTER PROCEDURE dbo.SPUpdateContrato
    @inContratoId INT, -- Par�metro de entrada: identificador del contrato a modificar
    @inNumeroContrato BIGINT, -- Par�metro de entrada: nuevo n�mero de contrato
    @inDocIdCliente INT, -- Par�metro de entrada: nuevo documento de identidad del cliente
    @inTipoTarifa INT, -- Par�metro de entrada: nuevo tipo de tarifa
    @outResultCode INT OUTPUT -- Par�metro de salida: c�digo de resultado de la ejecuci�n
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el n�mero de filas afectadas se devuelva como parte del resultado
    BEGIN TRY
        -- Inicializaci�n del c�digo de resultado
        SET @outResultCode = 0;

        -- Validar que el n�mero de contrato comienza con 8 o 9
        IF LEFT(CAST(@inNumeroContrato AS VARCHAR), 1) NOT IN ('8', '9')
        BEGIN
            SET @outResultCode = 50008; -- C�digo de error: N�mero de contrato no v�lido
            RETURN;
        END;

        -- Validar si el contrato existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Contratos WHERE Id = @inContratoId)
        BEGIN
            SET @outResultCode = 50012; -- C�digo de error: Contrato no existe
            RETURN;
        END;

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE Identificacion = @inDocIdCliente)
        BEGIN
            SET @outResultCode = 50009; -- C�digo de error: Cliente no existe
            RETURN;
        END;

        -- Validar si el tipo de tarifa existe
        IF NOT EXISTS (SELECT 1 FROM dbo.TiposTarifa WHERE Id = @inTipoTarifa)
        BEGIN
            SET @outResultCode = 50011; -- C�digo de error: Tipo de tarifa no v�lido
            RETURN;
        END;

        -- Actualizar el contrato
        UPDATE Contratos
        SET 
            Numero = @inNumeroContrato,
            DocIdCliente = @inDocIdCliente,
            TipoTarifa = @inTipoTarifa
        WHERE Id = @inContratoId;

        SET @outResultCode = 0; -- �xito
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50010; -- C�digo de error gen�rico

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
--    @inNumeroContrato = 877888, -- Reemplaza con el nuevo n�mero de contrato
--    @inDocIdCliente = 999999, -- Reemplaza con el nuevo documento de identidad del cliente
--    @inTipoTarifa = 3, -- Reemplaza con el nuevo tipo de tarifa
--    @outResultCode = @outResultCode OUTPUT;
--SELECT @outResultCode AS ResultCode;
