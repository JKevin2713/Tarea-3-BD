USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[ConsultaDetalleEmpresaXyY]    Script Date: 15/06/2024 15:41:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
--Este procedimiento busca los detalles de los cortes de la empresas Y y X  devuelve los detalles de la empresa correspondinte;
--si no, establece un código de error. Si ocurre un problema, registra el error y devuelve un código de error. Finalmente, 
--restaura el conteo de filas afectadas.

--Descripcion de parametros:
    -- @inBandera: Indica la empresa que se va a seleccionar
    -- @OutResultCode: resultado del insertado en la tabla

-- Notas adicionales:
-- El script se va corriendo iterandose día por día 
-- El EXEC se realiza en el SP de XMLInsertarDatosMasivos

--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ConsultaDetalleEmpresaXyY]
    @InBandera INT,	               -- Parámetro de búsqueda
	@InFechaCorte DATE,
    @OutResulTCode INT OUTPUT      -- Código de resultado de salida
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el mensaje "número de filas afectadas" se devuelva como parte del resultado

    BEGIN TRY
        -- Inicialización
        SET @OutResulTCode = 0;

        -- Lógica de búsqueda
        IF @InBandera IS NOT NULL
        BEGIN

			IF @InBandera = 0
			BEGIN
			    
				SELECT id, FechaCorte, FechaLlamada, Inicio,
                    Fin, Duracion, NumeroDe, NumeroA, TipoLlamada
				FROM LlamadasX LX
				WHERE LX.FechaCorte = @InFechaCorte
				ORDER BY 
					LX.FechaCorte ASC;
			END
			IF @InBandera = 1
			BEGIN
				SELECT id, FechaCorte, FechaLlamada, Inicio,
                    Fin, Duracion, NumeroDe, NumeroA, TipoLlamada
				FROM LlamadasY LY
				WHERE LY.FechaCorte = @InFechaCorte
				ORDER BY 
					LY.FechaCorte ASC;

			END;
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


