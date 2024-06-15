USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ConsultaClientes]    Script Date: 15/06/2024 15:41:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento sacan los datos de los clientes 

--Descripcion de parametros:
    -- @OutResultCode: resultado del insertado en la tabla

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[ConsultaClientes]
	@OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- se hacen inicializacion
        SET @OutResulTCode = 0;


        SELECT  cn.FechaOperacion AS fechaOperacion,
				c.Identificacion AS IdentificacionCliente,
				c.Nombre AS NombreCliente,
				cn.Numero AS NumeroContrato,
				t.Nombre AS NombreTipoTarifa
		FROM Contratos cn
		JOIN Clientes c ON cn.DocIdCliente = c.Identificacion
		JOIN TiposTarifa t ON cn.TipoTarifa = t.Id
		WHERE cn.Activo = 0
        ORDER BY cn.Id DESC;

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


