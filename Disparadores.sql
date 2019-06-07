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
/* trg_transfer 
CREATE TRIGGER trg_transfer ON Transferencia
INSTEAD OF INSERT
AS BEGIN
  IF((SELECT TipoTransfer FROM INSERTED) = 'E')
	BEGIN
		INSERT INTO Transferencia SELECT I.FchTransfer, I.IdMovim, I.TipoTransfer, NULL , I.BancoDestino , 'Auditoria'
									FROM INSERTED I
		
	END
   

END
GO
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

	--Desactivamos la PK para poder reingresar las cuentas con mismo IdCuenta
	ALTER TABLE Cuenta DROP CONSTRAINT PK_Cuenta_IdCuenta;
	--Desactivamos el Identity para que no encaje los numeros q se le antoje 
	SET IDENTITY_INSERT Cuenta OFF;

	--Duplicamos solo las cuentas que tienen el ID de la sucursal guardada en DELETED ( le colocamos el ID de la sucursal mas vieja)
	INSERT INTO Cuenta SELECT C.IdCuenta, C.IdTipo, C.IdMoneda, @sucursal_mas_vieja, C.IdCliente, C.SaldoCuenta FROM Cuenta C
																									WHERE C.IdSucursal = ( SELECT D.IdSucursal FROM DELETED D); 

	--Borramos todas las cuentas que posean el IdSucursal que pretendemos borrar (para poder borrar la sucursal precisamos que no hayan datos FK)
	DELETE FROM Cuenta WHERE IdSucursal = (SELECT D.IdSucursal FROM DELETED D);

	--Volvemos a crearle la PK
	ALTER TABLE Cuenta ADD CONSTRAINT PK_Cuenta_IdCuenta PRIMARY KEY (IdCuenta);
	--Volvemos a activar el Identity
	SET IDENTITY_INSERT Cuenta ON;

	--Se borra la sucursal ahora que no tiene datos FK:
	DELETE FROM Sucursal WHERE IdSucursal = (SELECT D.IdSucursal FROM DELETED D);

	/* Navegando por aguas turbias.. Pero bueno q se le v ase. */ 		
	/***j3j0***/																							
END
GO

/*
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Cuenta'
*/

