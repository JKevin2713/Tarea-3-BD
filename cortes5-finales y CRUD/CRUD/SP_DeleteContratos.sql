--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado elimina un contrato de un cliente ya creado en la base de datos

--Descripcion de parametros:
    --@inContratoId INT,
    --@OutResultCode INT OUTPUT
--------------------------------------------------------------------
CREATE PROCEDURE dbo.SP_DeleteContrato
    @inContratoId INT,
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicializaci�n del c�digo de resultado
        SET @OutResultCode = 0;

        -- Validar que el contrato existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Contratos WHERE Id = @inContratoId)
        BEGIN
            SET @OutResultCode = 50012; -- C�digo de error: ID de contrato no existe
            RETURN;
        END;

        -- Eliminar el contrato
        DELETE FROM Contratos WHERE Id = @inContratoId;

        SET @OutResultCode = 0; -- �xito
    END TRY
    BEGIN CATCH
        SET @OutResultCode = 50013; -- C�digo de error gen�rico para eliminaci�n

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


--DECLARE @outResultCode INT;
--EXEC dbo.SP_DeleteContrato @inContratoId = 210, @OutResultCode = @outResultCode OUTPUT;
--SELECT @outResultCode AS ResultCode;

--SELECT * FROM Contratos
