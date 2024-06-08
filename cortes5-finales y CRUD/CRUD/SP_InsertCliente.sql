--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, Mar�a F�lix M�ndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Este procedimiento almacenado inserta un cliente en tabla clientes 

--Descripcion de parametros:
    --@inValorDocumentoIdentidad: Par�metro de entrada: valor del documento de identidad del cliente
    --@inNombre VARCHAR(64): Par�metro de entrada: nombre del cliente (hasta 64 caracteres)
    --@inFechaOperacion DATE: Par�metro de entrada: fecha de operaci�n
    --@OutResultCode INT OUTPUT: Par�metro de salida: c�digo de resultado de la ejecuci�n
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SPInsertCliente]
    @inValorDocumentoIdentidad INT, -- Par�metro de entrada: valor del documento de identidad del cliente
    @inNombre VARCHAR(64), -- Par�metro de entrada: nombre del cliente (hasta 64 caracteres)
    @inFechaOperacion DATE = NULL, -- Par�metro de entrada: fecha de operaci�n
    @OutResultCode INT OUTPUT -- Par�metro de salida: c�digo de resultado de la ejecuci�n
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el n�mero de filas afectadas se devuelva como parte del resultado

    BEGIN TRY -- Inicia un bloque TRY para manejar excepciones
        -- Inicializaci�n del c�digo de resultado
        SET @OutResultCode = 0;

        -- Validaciones
        IF EXISTS (SELECT 1 FROM dbo.Clientes WHERE Nombre = @inNombre)
        BEGIN
            SET @OutResultCode = 50006; -- C�digo de error: Nombre de Cliente ya existe
            RETURN; -- Retorna inmediatamente, saliendo del procedimiento almacenado
        END;

        IF EXISTS (SELECT 1 FROM dbo.Clientes WHERE Identificacion = @inValorDocumentoIdentidad)
        BEGIN
            SET @OutResultCode = 50007; -- C�digo de error: Identificaci�n de Cliente ya existe
            RETURN; -- Retorna inmediatamente, saliendo del procedimiento almacenado
        END;

        -- Si la fecha de operaci�n no se proporciona, establecerla en la fecha actual
        IF @inFechaOperacion IS NULL
        BEGIN
            SET @inFechaOperacion = GETDATE();
        END;

        -- Inserta un nuevo cliente en la tabla Clientes
        INSERT INTO Clientes(Identificacion, Nombre, FechaOperacion)
        VALUES (@inValorDocumentoIdentidad, @inNombre, @inFechaOperacion);
        SET @OutResultCode = 0;
    END TRY
    BEGIN CATCH -- Si ocurre alguna excepci�n, entra en este bloque
        -- Establece el c�digo de resultado en 50005 (error)
        SET @OutResultCode = 50005;

        IF @@TRANCOUNT > 0 -- Verifica si hay una transacci�n en curso
            ROLLBACK TRAN; -- Revierte la transacci�n

        -- Registra el error en la tabla DBError
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
    END CATCH; -- Fin del bloque CATCH

    SET NOCOUNT OFF; -- Restaura el recuento de filas afectadas para las instrucciones SELECT, INSERT, UPDATE y DELETE
END;





--DECLARE @resultCode INT;

--EXEC dbo.SPInsertCliente 
--    @inValorDocumentoIdentidad = 14141414,
--    @inNombre = 'DARIO',
--    @inFechaOperacion = '2023-06-09', -- Puedes pasar una fecha espec�fica o dejarlo vac�o para usar la fecha actual
--    @OutResultCode = @resultCode OUTPUT;


--SELECT @resultCode AS ResultCode;

--SELECT * FROM Clientes
