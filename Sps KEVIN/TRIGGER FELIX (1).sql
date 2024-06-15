--------------------------------------------------------------------
--Jefferson Salas, Kevin Jimenez, María Félix Méndez 
-- Tarea Programada 03 | Base de Datos I

-- Stored Procedure:
-- Crea el trigger qu hace la relacion de elementos de tipo tarifa con los elementos fijos de la tabla de elementos y lo guarda en la tabla de
-- ElementosTipoTarifa
-------------------------------------------------------------------
CREATE TRIGGER [dbo].[AsociarElementosFijos]
ON [dbo].[TiposTarifa]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ElementoDeTipoTarifa (idTipoTarifa, idTipoElemento, Valor)
    SELECT 
        i.id,
        TE.Id,
        TE.Valor 
    FROM 
        inserted i
    INNER JOIN 
        dbo.TiposElemento TE ON TE.EsFijo = 1
END;
GO
