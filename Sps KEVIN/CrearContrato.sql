USE [Tarea4]
GO

/****** Object:  StoredProcedure [dbo].[CrearContrato]    Script Date: 15/06/2024 15:44:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado Inserta un contrato de un cliente ya creado en la base de datos

--Descripcion de parametros:
    --@inNumeroContrato BIGINT,
    --@inDocIdCliente INT,
    --@inTipoTarifa INT,
    --@inFechaOperacion DATE = NULL,
    --@OutResultCode INT OUTPUT
--------------------------------------------------------------------

CREATE PROCEDURE [dbo].[CrearContrato]
    @inDocIdCliente INT,
    @inTipoTarifa INT,
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicialización del código de resultado
		DECLARE @FechaActial DATE,
				@NumeroAleatorio BIGINT,
				@Existe BIT = 1;
        SET @OutResultCode = 0;
		SET @FechaActial = GETDATE();

       -- Ciclo para generar un número aleatorio único
		WHILE @Existe = 1
		BEGIN
			-- Generar un número aleatorio de 8 dígitos
			SET @NumeroAleatorio = CAST((RAND() * 90000000) + 10000000 AS BIGINT);

			-- Comprobar si el número ya existe en la tabla Contratos
			IF EXISTS (SELECT 1 FROM [dbo].[Contratos] WHERE Numero = @NumeroAleatorio)
			BEGIN
				-- Si el número existe, continuar el ciclo
				SET @Existe = 1;
			END
			ELSE
			BEGIN
				-- Si el número no existe, salir del ciclo
				SET @Existe = 0;
			END
		END;


		BEGIN TRANSACTION;

			-- Insertar el nuevo contrato
			INSERT INTO Contratos (Numero, DocIdCliente, TipoTarifa, FechaOperacion, Activo)
			VALUES (@NumeroAleatorio, @inDocIdCliente, @inTipoTarifa, @FechaActial, 0);


			EXEC [dbo].[agregarDetallesDeCobro] @InFechaOperacion = @FechaActial,  @outResultCode = 0
			EXEC [dbo].[agregarFactura] @InFechaOperacion = @FechaActial, @InCrearFactura = 0,  @outResultCode = 0;

					-- Confirmar la transacción si todo está bien
        COMMIT TRANSACTION;

        SET @OutResultCode = 0; -- Éxito
    END TRY
    BEGIN CATCH
        SET @OutResultCode = 50010; -- Código de error genérico

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

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
    END CATCH;
    SET NOCOUNT OFF;
END;
GO


