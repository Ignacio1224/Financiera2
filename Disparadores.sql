/* Procedimientos Almacenados */

/* Autor: Ignacio Cabrera - Santiago Manzoni */

/* NOTA: Se asume que el año corriente es el actual. */

/*
  CREATE TABLE AUDITORIA
        (
            idAudit INT PRIMARY KEY  IDENTITY (1, 1) NOT NULL,
            fchAudit DATETIME NOT NULL,
            idMovim NUMERIC(5,0) REFERENCES Movimiento(IdMovim) NOT NULL,
            idCliente NUMERIC(5,0) REFERENCES Cliente(idCliente) NOT NULL,
            nombreCliente VARCHAR (255) NOT NULL,
            importeAnterior DECIMAL (18, 2) NOT NULL,
            importeActual DECIMAL (18, 2) NOT NULL,
			INDEX IX_idMovim(idMovim),
            INDEX IX_idCliente(idCliente)
        );
*/


USE OBLBD2;
GO

--(2)(a)
/*El trigger A no puede ser realizado debido a que la letra es inconsistente.
-En caso de que el INSERT fuese abordado desde la tabla Movimiento estaría faltando la información que especifica
si es de tipo INTERNA o EXTERNA.
-En caso que el INSERT se diese sobre la tabla Transferencia, sucedería que una tupla de dicha tabla nos pide que
 le ingresemos un IdMovimiento, cosa que no habría forma de obtener si no es que existe previo 
 un insert en Movimiento antes ).
*/


--(2)(b)
--trg_modif_mov
CREATE TRIGGER trg_modif_mov ON Movimiento
AFTER UPDATE
AS BEGIN

	DECLARE @importe_anterior DECIMAL(18,2) = (SELECT ImporteMovim FROM DELETED); 

	DECLARE @nombre_cliente VARCHAR(100) = (SELECT C.NombreCliente FROM Cliente C
											 JOIN Cuenta Cu  ON C.IdCliente =  Cu.IdCliente 
											 JOIN DELETED D ON D.IdCuenta = Cu.IdCuenta);

	DECLARE @id_cliente INT = (SELECT C.IdCliente FROM Cliente C
											 JOIN Cuenta Cu  ON C.IdCliente =  Cu.IdCliente 
											 JOIN DELETED D ON D.IdCuenta = Cu.IdCuenta);


	INSERT INTO AUDITORIA SELECT GETDATE(), I.IdMovim, @id_cliente, @nombre_cliente, @importe_anterior, I.ImporteMovim 
						   FROM INSERTED I;
END
GO

--(2)(c)
/* trg_Denegar_Salida_Sin_Saldo */
CREATE TRIGGER trg_Denegar_Salida_Sin_Saldo ON Movimiento
    AFTER INSERT
AS BEGIN

	DECLARE @saldo_cuenta DECIMAL(18,2) = ( SELECT SUM(M.ImporteMovim)
												FROM Movimiento M, INSERTED I
													WHERE M.IdCuenta = I.IdCuenta
													AND M.TipoMovim = 'E') - (SELECT SUM(M.ImporteMovim)
																					FROM Movimiento M, INSERTED I
																						WHERE M.IdCuenta = I.IdCuenta
																						AND M.TipoMovim <> 'E');

    IF((SELECT I.ImporteMovim FROM INSERTED I) > @saldo_cuenta)
		BEGIN
			ROLLBACK;
		END   
END
GO

--(2)(d)
/* trg_control_cuenta */
CREATE TRIGGER trg_control_cuenta ON Cuenta
    AFTER INSERT
AS BEGIN
        IF EXISTS( SELECT 1 FROM Cuenta C, INSERTED I
					WHERE C.IdCliente = I.IdCliente
					AND C.IdMoneda = I.IdMoneda
					AND C.IdSucursal = I.IdSucursal )
			BEGIN
				ROLLBACK;
			END
    END
GO

--(2)(e)
/* trg_borrar_sucursal */
CREATE TRIGGER trg_borrar_sucursal ON Sucursal
    INSTEAD OF DELETE
AS BEGIN
    DECLARE @sucursal_mas_vieja CHAR(5) = (SELECT S.IdSucursal FROM Sucursal S 
											JOIN Cuenta Cu ON Cu.IdSucursal = S.IdSucursal
											JOIN Movimiento M ON Cu.IdCuenta = M.IdCuenta
												WHERE M.FchMovim <= ALL(SELECT Mv.FchMovim FROM Movimiento Mv));


	UPDATE Cuenta SET IdSucursal = @sucursal_mas_vieja 
	WHERE IdSucursal = (SELECT D.IdSucursal FROM DELETED D);

	DELETE FROM Sucursal WHERE IdSucursal = (SELECT D.IdSucursal FROM DELETED D);
																						
END
GO

/*
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Cuenta'
*/

