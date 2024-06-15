USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[procesarPagoFactura]    Script Date: 15/06/2024 15:48:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento se encarga de marcar una factura como pagada y, si es necesario, realiza acciones adicionales
--relacionadas con la factura, como la inserción de datos y la creación de una nueva factura.

--Descripcion de parametros:
	-- @inNumero: Numero que se anda buscando 
    -- @inFechaOperacion: Valor de la fecha que se iterando día por día cuando se insertan los datos masivos
    -- @outResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[procesarPagoFactura]
    @inNumero BIGINT, --Numero
    @inFechaOperacion DATE, --Fcha
	@OutResulTCode INT OUTPUT      -- Código de resultado de salida
AS
BEGIN
	SET NOCOUNT ON; -- Evita que el mensaje "número de filas afectadas" se devuelva como parte del resultado
    BEGIN TRY
        BEGIN TRANSACTION PagoFactura;

		DECLARE @ID INT,
				@Multa DECIMAL(18,2);

		SELECT TOP 1 @ID = Id
		FROM Factura
		WHERE IdNumero = @InNumero AND FacturaPagada = 0

		SELECT @Multa = MultaFacturaPendiente
		FROM Factura
		WHERE Id = @ID

        -- Actualizar el estado de la factura a pagada
        UPDATE [dbo].[Factura]
        SET FacturaPagada = 1
        WHERE Id = @ID;

        -- Aquí podrías agregar más lógica si es necesario para validar el pago

		IF @Multa = 0.00
		BEGIN
			 -- Llamar al procedimiento para crear una nueva factura
			EXEC [dbo].[InsertarDatosFactura] @InIdFactura = @ID, @inNumero = @InNumero, @OutResulTCode = 0;
			EXEC [dbo].[crearFactura] @InNumero = @InNumero, @inFechaOperacion = @InFechaOperacion, @OutResulTCode = 0;
		END 

        COMMIT TRANSACTION; 
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


