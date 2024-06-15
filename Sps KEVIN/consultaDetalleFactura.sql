USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[consultaDetalleFactura]    Script Date: 15/06/2024 15:42:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento busca los detalles de una factura según su ID. Si el ID es válido, devuelve los detalles de la factura;
--si no, establece un código de error. Si ocurre un problema, registra el error y devuelve un código de error. Finalmente, 
--restaura el conteo de filas afectadas.

--Descripcion de parametros:
    -- @inIdFactura Valor del id de la factura
    -- @OutResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[consultaDetalleFactura]
    @inIdFactura INT,              -- Parámetro de búsqueda
    @OutResulTCode INT OUTPUT      -- Código de resultado de salida
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el mensaje "número de filas afectadas" se devuelva como parte del resultado

    BEGIN TRY
        -- Inicialización
        SET @OutResulTCode = 0;

        -- Lógica de búsqueda
        IF @inIdFactura IS NOT NULL
        BEGIN
            -- Si hay coincidencias por nombre, seleccionar empleados activos cuyos nombres coincidan con @buscar
            SELECT id, TarifaBasica, MinutosExceso, GigasExceso, MinutosLlamadaFamiliar,
                    Cobro911, Cobro110, Cobro900, Cobro800
            FROM DetalleElementoCobro 
            WHERE IdFactura = @inIdFactura;
        END
        ELSE
        BEGIN
            -- Establece el código de resultado de salida en caso de que el parámetro de búsqueda sea nulo
            SET @OutResulTCode = 50002;
        END;

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


