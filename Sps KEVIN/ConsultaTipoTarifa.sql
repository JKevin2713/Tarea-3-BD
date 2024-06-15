USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ConsultaTipoTarifa]    Script Date: 15/06/2024 15:43:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento sacar los tipos de tarifas

--Descripcion de parametros:
    -- @OutResultCode: resultado del insertado en la tabla

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[ConsultaTipoTarifa]
	@OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- se hacen inicializacion
        SET @OutResulTCode = 0;


        SELECT Id, Nombre FROM dbo.TiposTarifa;
        
        -- Data sets se especifican al final y todos juntos
        SET @OutResulTCode = 0

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; 
		
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
		SELECT @OutResulTCode AS OutResultCode;
	END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;
GO


