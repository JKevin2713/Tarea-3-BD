--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado que consulta un contrato de un cliente ya creado en la base de datos

--Descripcion de parametros:
    --@inContratoId INT,
    --@OutResultCode INT OUTPUT
--------------------------------------------------------------------

CREATE PROCEDURE dbo.SPConsultarContrato
    @inContratoId INT, -- Parámetro de entrada: identificador del contrato a consultar
    @outResultCode INT OUTPUT -- Parámetro de salida: código de resultado de la ejecución
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicialización del código de resultado
        SET @outResultCode = 0;

        -- Seleccionar los datos del contrato
        SELECT 
            @outResultCode AS outResultCode,
            C.Id AS 'Contrato Id',
            C.Numero AS 'Numero Contrato',
            C.DocIdCliente AS 'Documento Identidad Cliente',
            C.TipoTarifa AS 'Tipo Tarifa',
            C.FechaOperacion AS 'Fecha Operacion'
        FROM Contratos C
        WHERE C.Id = @inContratoId;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        INSERT INTO DBError (
            UserName,
            ErrorNumber,
            ErrorState,
            ErrorSeverity,
            ErrorLine,
            ErrorProcedure,
            ErrorMessage,
            ErrorDate
        ) VALUES (
            SUSER_SNAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50014; -- Código de error: Contrato no encontrado o error de ejecución
        SELECT @outResultCode AS outResultCode;
    END CATCH;
    SET NOCOUNT OFF;
END;


--SELECT * FROM Contratos
--DECLARE @outResultCode INT;
--EXEC dbo.SPConsultarContrato @inContratoId = 8, @outResultCode = @outResultCode OUTPUT;
--SELECT @outResultCode AS ResultCode;
