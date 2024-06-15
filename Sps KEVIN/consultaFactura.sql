USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[consultaFactura]    Script Date: 15/06/2024 15:42:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento busca los detalles de una factura en la tabla Factura seg�n el n�mero de factura proporcionado 
-- y maneja los errores que puedan ocurrir durante el proceso.

--Descripcion de parametros:
    -- @inNumeroBuscar: Numero a buscar 
    -- @OutResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose d�a por d�a 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[consultaFactura]
    @inNumeroBuscar NVARCHAR(100),      -- Par�metro de b�squeda
    @OutResulTCode INT OUTPUT   -- C�digo de resultado de salida
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el mensaje "n�mero de filas afectadas" se devuelva como parte del resultado

    BEGIN TRY
        -- Inicializaci�n
        SET @OutResulTCode = 0;

        -- L�gica de b�squeda
        IF @inNumeroBuscar IS NOT NULL
        BEGIN
			WITH CTE AS (
				SELECT f.id, IdNumero, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente,
					   TotalPagoMulta, FechaPagoFactura, FechaDiaGraciaPago, FacturaPagada,
					   ROW_NUMBER() OVER (PARTITION BY YEAR(FechaPagoFactura), MONTH(FechaPagoFactura) ORDER BY FechaPagoFactura ASC) AS RowNum
				FROM Factura f
				JOIN Contratos c ON f.IdNumero = c.Numero
				WHERE IdNumero = @inNumeroBuscar 
				  AND c.Activo = 0
			)
			SELECT id, IdNumero, TotalPagoAntesIva, TotalPagoDespuesIva, MultaFacturaPendiente,
				   TotalPagoMulta, FechaPagoFactura, FechaDiaGraciaPago, FacturaPagada 
			FROM CTE
			WHERE RowNum = 1;
        END
        ELSE
        BEGIN
            -- Establece el c�digo de resultado de salida en caso de que el par�metro de b�squeda sea nulo
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

        -- Establecer el c�digo de resultado de salida en error
        SET @OutResultCode = 50008;
        SELECT @OutResultCode AS OutResultCode;
    END CATCH;
    SET NOCOUNT OFF; -- Restaurar el conteo de filas afectadas
END;
GO


