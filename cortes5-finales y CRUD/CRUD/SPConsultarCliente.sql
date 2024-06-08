--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado actualiza un cliente de la tabla clientes 

--Descripcion de parametros:
    --@inIdCliente: Par�metro de entrada: identificador del cliente a consultar
    --@outResultCode: Par�metro de salida: c�digo de resultado de la ejecuci�n
--------------------------------------------------------------------
CREATE PROCEDURE dbo.SPConsultarCliente
    @inIdCliente INT, -- Par�metro de entrada: identificador del cliente a consultar
    @outResultCode INT OUTPUT -- Par�metro de salida: c�digo de resultado de la ejecuci�n
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        
        -- INICIALIZAR VARIABLES:
        
        SET @outResultCode = 0;

        -- ------------------------------------------------------------- --
        -- GENERAR DATASETS:
        
        -- Seleccionar los datos del cliente
        SELECT 
            @outResultCode AS outResultCode,
            C.Identificacion AS 'Documento Identidad',
            C.Nombre AS 'Nombre',
            C.FechaOperacion AS 'Fecha Operacion'
        FROM Clientes C
        WHERE C.Id = @inIdCliente;

        -- ------------------------------------------------------------- --

    END TRY

    BEGIN CATCH
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

        SET @outResultCode = 50008; -- C�digo de error: Cliente no encontrado o error de ejecuci�n
        SELECT @outResultCode AS outResultCode;
    END CATCH;
    SET NOCOUNT OFF;
END;



--DECLARE @ResultCode INT;

--EXEC [dbo].[SPConsultarCliente]
--    @inIdCliente = 179, -- Reemplaza 1 con el ID del cliente que deseas consultar
--    @OutResultCode = @ResultCode OUTPUT;

---- Mostrar el resultado
--SELECT @ResultCode AS ResultCode;

--SELECT * FROM Clientes