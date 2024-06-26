--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado actualiza un cliente de la tabla clientes 

--Descripcion de parametros:
    --@inIdEmpleado: Parámetro de entrada: identificador del empleado a modificar
    --@inNombre VARCHAR(64): Parámetro de entrada: nuevo nombre del empleado
    --@inValorDocumentoIdentidad INT -- Parámetro de entrada: nuevo valor del documento de identidad del empleado
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_UpdateClientes]
    @inIdEmpleado INT, -- Parámetro de entrada: identificador del empleado a modificar
    @inNombre VARCHAR(64), -- Parámetro de entrada: nuevo nombre del empleado
    @inValorDocumentoIdentidad INT -- Parámetro de entrada: nuevo valor del documento de identidad del empleado
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el número de filas afectadas se devuelva como parte del resultado
	BEGIN TRY

    -- Verifica si el empleado con el ID proporcionado existe en la tabla
    IF EXISTS (SELECT 1 FROM Clientes WHERE id = @inIdEmpleado)
    BEGIN
        -- Actualiza el nombre, el valor del documento de identidad y el ID del puesto del empleado
        UPDATE Clientes
        SET 
            Nombre = @inNombre,
            Identificacion = @inValorDocumentoIdentidad
        WHERE id = @inIdEmpleado;

        -- Devuelve un mensaje de éxito
        SELECT 'Empleado modificado correctamente.' AS Mensaje;
    END
	END TRY

    BEGIN CATCH -- Si ocurre alguna excepción, entra en este bloque

        IF @@TRANCOUNT > 0 -- Verifica si hay una transacción en curso
            ROLLBACK TRAN; -- Revierte la transacción

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
    END CATCH; -- Fin del bloque CATCH

    SET NOCOUNT OFF; -- Restaura el recuento de filas afectadas para las instrucciones SELECT, INSERT, UPDATE y DELETE
END;

--EXEC [dbo].[SP_UpdateClientes]
--    @inIdEmpleado = 179, -- Reemplaza 1 con el ID del empleado que deseas modificar
--    @inNombre = 'Felix Méndez', -- Reemplaza 'Nuevo Nombre' con el nuevo nombre del empleado
--    @inValorDocumentoIdentidad = 999999; -- Reemplaza 123456789 con el nuevo valor del documento de identidad
--SELECT * FROM Clientes