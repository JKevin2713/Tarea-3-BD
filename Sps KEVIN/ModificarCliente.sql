USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ModificarCliente]    Script Date: 15/06/2024 15:46:15 ******/
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

CREATE PROCEDURE [dbo].[ModificarCliente]
	@InIdNumero BIGINT, 
	@InNombre VARCHAR(255),
	@InTipoTarifa INT,
	@InBandera BIT,
	@OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
		
		DECLARE @Cedula INT;
        -- Inicialización
        SET @OutResulTCode = 0;

        IF @InBandera = 0
        BEGIN
            -- Selección de los datos cuando la bandera es 0

			SELECT c.Nombre
			FROM Contratos cn
			JOIN Clientes c ON cn.DocIdCliente = c.Identificacion
			JOIN TiposTarifa t ON cn.TipoTarifa = t.Id
			WHERE cn.Numero = @InIdNumero 
				AND cn.Numero = @InIdNumero;

			RETURN 
        END
        ELSE IF @InBandera = 1
        BEGIN
            -- Comenzar una transacción para asegurar la atomicidad de las operaciones
            BEGIN TRANSACTION;
            
			SELECT @Cedula = C.Identificacion
			FROM Clientes C
			JOIN Contratos CL ON C.Identificacion = CL.DocIdCliente
			WHERE CL.Numero = @InIdNumero;

            -- Actualizar la tabla Clientes
            UPDATE Clientes
            SET Nombre = @InNombre
            WHERE Identificacion = @Cedula;

            -- Actualizar la tabla Contratos
            UPDATE Contratos
            SET TipoTarifa = @InTipoTarifa
            WHERE DocIdCliente = @Cedula;

            -- Confirmar la transacción si todo está bien
            COMMIT TRANSACTION;
        END

        -- Establecer el código de resultado de salida en éxito
        SET @OutResulTCode = 0;

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


