/* Disparadores */
/*
    Autor: Ignacio Cabrera - Santiago Manzoni
*/

/*
    NOTA: Se asume que el año corriente es el actual.
*/



USE OBLBD2;
GO



/* trg_transfer */
CREATE TRIGGER trg_transfer ON Movimientos
    INSTEAD OF INSERT, UPDATE
AS BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM Movimiento
END


/* trg_modif_mov */
CREATE TRIGGER trg_modif_mov ON Movimiento
    INSTEAD OF UPDATE
AS BEGIN
    /* Crea la tabla Auditoria si no existe */
    IF (EXISTS (
            SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE 
                TABLE_SCHEMA = 'OBLBD2'
        AND TABLE_NAME = 'AUDITORIA'
            )
        )
    BEGIN
        CREATE TABLE AUDITORIA
        (
            idAudit INT IDENTITY (1, 1) NOT NULL,
            fchAudit DATETIME NOT NULL,
            idMovim INT NOT NULL,
            idCliente INT NOT NULL,
            nombreCliente VARCHAR (255) NOT NULL,
            importeAnterior DECIMAL (18, 2) NOT NULL,
            importeActual DECIMAL (18, 2) NOT NULL,

            ADD CONSTRAINT pk_audit PRIMARY KEY
            (idAudit),
            ADD CONSTRAINT fk_movim FOREIGN KEY
            (idMovim) REFERENCES Movimiento
            (idMovim),
            ADD CONSTRAINT fk_cliente FOREIGN KEY
            (idCliente) REFERENCES Cliente
            (idCliente),

            INDEX IX_idMovim
            (idMovim),
            INDEX IX_idCliente
            (idCliente)

        );
    END
    
END



/* trg_Denegar_Salida_Sin_Saldo */
CREATE TRIGGER trg_Denegar_Salida_Sin_Saldo ON Movimiento
    INSTEAD OF INSERT, UPDATE
AS BEGIN
        SELECT *
        FROM Moneda
    END



/* trg_control_cuenta */
CREATE TRIGGER trg_control_cuenta ON Movimiento
    INSTEAD OF INSERT, UPDATE
AS BEGIN
        SELECT *
        FROM Moneda
    END



/* trg_borrar_sucursal */
CREATE TRIGGER trg_borrar_sucursal ON Movimiento
    INSTEAD OF INSERT, UPDATE
AS BEGIN
    SELECT *
    FROM Moneda
END

