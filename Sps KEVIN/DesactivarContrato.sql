USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[DesactivarContrato]    Script Date: 15/06/2024 15:44:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento para eliminar un cliente 

--Descripcion de parametros:
    -- @OutResultCode: resultado del insertado en la tabla

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[DesactivarContrato]
    @InNumeroDelContrato BIGINT,
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Actualizar el campo Activo a 1 para el contrato con el número especificado
        UPDATE Contratos
        SET Activo = 1
        WHERE Numero = @InNumeroDelContrato;

        -- Establecer el código de resultado de salida en éxito
        SET @OutResultCode = 0;
    END TRY
    BEGIN CATCH
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

        -- Establecer el código de resultado de salida en error
        SET @OutResultCode = 50008;
    END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;
GO


