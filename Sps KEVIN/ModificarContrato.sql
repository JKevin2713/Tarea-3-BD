USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ModificarContrato]    Script Date: 15/06/2024 15:46:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento sacan los datos de los clientes 

--Descripcion de parametros:
    -- @OutResultCode: resultado del insertado en la tabla

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[ModificarContrato]
	@InIdNumero BIGINT, 
	@InTipoTarifa INT,
	@InBandera BIT,
	@OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicializaci�n
        SET @OutResulTCode = 0;

        IF @InBandera = 0
        BEGIN
            -- Selecci�n de los datos cuando la bandera es 0

			SELECT cn.Numero, c.Nombre
			FROM Contratos cn
			JOIN Clientes c ON cn.DocIdCliente = c.Identificacion
			JOIN TiposTarifa t ON cn.TipoTarifa = t.Id
			WHERE cn.Numero = @InIdNumero 
				AND cn.Numero = @InIdNumero;

			RETURN 
        END
        ELSE IF @InBandera = 1
        BEGIN
            -- Comenzar una transacci�n para asegurar la atomicidad de las operaciones
            BEGIN TRANSACTION;


            -- Actualizar la tabla Contratos
            UPDATE Contratos
            SET TipoTarifa = @InTipoTarifa
            WHERE Numero = @InIdNumero;

				-- Confirmar la transacci�n si todo est� bien
            COMMIT TRANSACTION;
        END

        -- Establecer el c�digo de resultado de salida en �xito
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

		-- Establecer el c�digo de resultado de salida en error
		SET @OutResultCode = 50008;
		SELECT @OutResulTCode AS OutResultCode;
	END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;
GO


