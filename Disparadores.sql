/* Disparadores */
/*
    Autor: Ignacio Cabrera - Santiago Manzoni
*/

/*
    NOTA: Se asume que el año corriente es el actual.
*/



USE OBLBD2;
GO



/* tr_transfer */
CREATE TRIGGER tr_transfer ON Movimientos
    BEFORE INSERT UPDATE
BEGIN

END



/* tr_modif_mov */
CREATE TRIGGER tr_modif_mov ON Movimiento
    BEFORE UPDATE
BEGIN
    /* Crea la tabla Auditoria si no existe */
    IF (EXISTS (
            SELECT * 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE 
                TABLE_SCHEMA = 'OBLBD2' 
                AND  TABLE_NAME = 'AUDITORIA'
            )
        )
    BEGIN
        CREATE TABLE AUDITORIA (
            idAudit INT IDENTITY (1, 1) NOT NULL,
            fchAudit DATETIME NOT NULL,
            idMovim INT NOT NULL,
            idCliente INT NOT NULL,
            nombreCliente VARCHAR (255) NOT NULL,
            importeAnterior DECIMAL (18, 2) NOT NULL,
            importeActual DECIMAL (18, 2) NOT NULL

            ADD CONSTRAINT pk_audit PRIMARY KEY (idAudit),
            ADD CONSTRAINT fk_movim FOREIGN KEY (idMovim) REFERENCES Movimiento (idMovim),
            ADD CONSTRAINT fk_cliente FOREIGN KEY (idCliente) REFERENCES Cliente (idCliente),

            INDEX IX_idMovim (idMovim),
            INDEX IX_idCliente (idCliente)

        );
    END
    
END
