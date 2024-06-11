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

CREATE PROCEDURE dbo.SPInsertarContrato
    @inNumeroContrato BIGINT,
    @inDocIdCliente INT,
    @inTipoTarifa INT,
    @inFechaOperacion DATE = NULL,
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inicialización del código de resultado
        SET @OutResultCode = 0;

        -- Validar que el número de contrato comienza con 8 o 9
        IF LEFT(CAST(@inNumeroContrato AS VARCHAR), 1) NOT IN ('8', '9')
        BEGIN
            SET @OutResultCode = 50008; -- Código de error: Número de contrato no válido
            RETURN;
        END;

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE Identificacion = @inDocIdCliente)
        BEGIN
            SET @OutResultCode = 50009; -- Código de error: Cliente no existe
            RETURN;
        END;

        -- Validar si el tipo de tarifa existe
        IF NOT EXISTS (SELECT 1 FROM dbo.TiposTarifa WHERE Id = @inTipoTarifa)
        BEGIN
            SET @OutResultCode = 50011; -- Código de error: Tipo de tarifa no válido
            RETURN;
        END;

        -- Si la fecha de operación no se proporciona, establecerla en la fecha actual
        IF @inFechaOperacion IS NULL
        BEGIN
            SET @inFechaOperacion = GETDATE();
        END;

        -- Insertar el nuevo contrato
        INSERT INTO Contratos (Numero, DocIdCliente, TipoTarifa, FechaOperacion)
        VALUES (@inNumeroContrato, @inDocIdCliente, @inTipoTarifa, @inFechaOperacion);

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



--SELECT * FROM Clientes
----SELECT * FROM Contratos
--DECLARE @outResultCode INT;

--EXEC dbo.SPInsertarContrato
--    @inNumeroContrato = 9087528,   -- Reemplaza con el número del contrato
--    @inDocIdCliente = 14141414,   -- Reemplaza con el documento de identidad del cliente
--    @inTipoTarifa = 2,            -- Reemplaza con el tipo de tarifa
--    @inFechaOperacion = '2023-06-07',      -- Opcional: Reemplaza con la fecha de operación si es necesario
--    @OutResultCode = @outResultCode OUTPUT; -- Parámetro de salida

--SELECT @outResultCode AS ResultCode;
