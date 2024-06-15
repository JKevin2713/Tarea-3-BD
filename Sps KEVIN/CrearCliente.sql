USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[CrearCliente]    Script Date: 15/06/2024 15:44:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento para ingresar un cliente nuevo

--Descripcion de parametros:
    -- @OutResultCode: resultado del insertado en la tabla

--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[CrearCliente]
	@InCedula INT, 
	@InNombre VARCHAR(255),
	@OutResulTCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
		
		DECLARE @FechaActial DATE;
        -- Inicializaci�n
        SET @OutResulTCode = 0;
		SET @FechaActial = GETDATE();

		        -- Validaciones
        IF EXISTS (SELECT 1 FROM dbo.Clientes WHERE Nombre = @InNombre)
        BEGIN
            SET @OutResultCode = 50006; -- C�digo de error: Nombre de Cliente ya existe
            RETURN; -- Retorna inmediatamente, saliendo del procedimiento almacenado
        END;

        IF EXISTS (SELECT 1 FROM dbo.Clientes WHERE Identificacion = @InCedula)
        BEGIN
            SET @OutResultCode = 50007; -- C�digo de error: Identificaci�n de Cliente ya existe
            RETURN; -- Retorna inmediatamente, saliendo del procedimiento almacenado
        END;


        BEGIN TRANSACTION;
            
			INSERT INTO [dbo].[Clientes] (
				Identificacion,
				Nombre,
				FechaOperacion)
            VALUES(
				@InCedula,
                @InNombre,
				@FechaActial)

        -- Confirmar la transacci�n si todo est� bien
        COMMIT TRANSACTION;


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


