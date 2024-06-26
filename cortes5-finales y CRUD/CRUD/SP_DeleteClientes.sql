--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado elimina un cliente de la tabla clientes 

--Descripcion de parametros:
     --@idEmpleado INT: id del cliente a eliminar 
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_DeleteClientes]
    @idEmpleado INT
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el número de filas afectadas se devuelva como parte del resultado
    
    BEGIN TRY -- Inicia un bloque TRY para manejar excepciones
        
        BEGIN TRANSACTION; -- Inicia una transacción
        
        -- Elimina el empleado de la tabla Empleado
        DELETE FROM Clientes WHERE Id = @idEmpleado;
        
        COMMIT TRANSACTION; -- Confirma la transacción
        
    END TRY
    
    BEGIN CATCH -- Si ocurre alguna excepción, entra en este bloque
        -- Si hay una transacción en curso, la revierte
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Registra el error en la tabla DBErrors
                -- Registrar el error
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
        
        -- Maneja la excepción
        THROW;
    END CATCH; -- Fin del bloque CATCH

    SET NOCOUNT OFF; -- Restaura el recuento de filas afectadas para las instrucciones SELECT, INSERT, UPDATE y DELETE
END; -- Fin del procedimiento almacenado




--select * from Empleado
--exec [dbo].[SP_DeleteClientes]
--    @idEmpleado = 180

--SELECT * FROM Clientes