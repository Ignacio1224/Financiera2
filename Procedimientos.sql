/* Procedimientos Almacenados */

/* Autor: Ignacio Cabrera - Santiago Manzoni */

/* NOTA: Se asume que el año corriente es el actual. */

USE OBLBD2;
GO

--(1)(a)
/* SaldosDeCuentaCliente */
CREATE PROCEDURE SaldosDeCuentaCliente
    @cuenta INT = 0, /* Numero de cuenta a evaluar */
    @fch_inicio DATE = GETDATE, /* Fecha de inicio de la evaluación */
    @fch_fin DATE = GETDATE, /*  Fecha de fin de la evaluación */
    @saldo_anterior DECIMAL (18, 2) = 0 OUTPUT, /* Saldo anterior a la fecha de fin */
    @saldo_actual DECIMAL (18, 2) = 0 OUTPUT /* Saldo actual a la fecha de fin */
AS BEGIN

	SET @saldo_actual = (SELECT SUM (Me.ImporteMovim)
						 FROM Movimiento Me 
							WHERE 
								Me.TipoMovim = 'E' 
								AND Me.IdCuenta = @cuenta 
								AND Me.FchMovim BETWEEN @fch_inicio AND @fch_fin
							GROUP BY Me.IdCuenta ) - ( SELECT SUM (Ms.ImporteMovim) 
														FROM Movimiento Ms 
															WHERE 
																Ms.TipoMovim <> 'E' 
																AND Ms.IdCuenta = @cuenta 
																AND Ms.FchMovim BETWEEN @fch_inicio AND @fch_fin 
															GROUP BY Ms.IdCuenta);

	SET @saldo_anterior = ( SELECT SUM (Me.ImporteMovim) 
							FROM Movimiento Me 
								WHERE
									Me.TipoMovim = 'E' 
									AND Me.IdCuenta = @cuenta 
									AND Me.FchMovim BETWEEN -53690 AND @fch_inicio 
								GROUP BY Me.IdCuenta ) - ( SELECT SUM (Ms.ImporteMovim) 
																	FROM Movimiento Ms 
																		WHERE 
																		Ms.TipoMovim <> 'E' 
																		AND Ms.IdCuenta = @cuenta
																		AND Ms.FchMovim BETWEEN -53690 AND @fch_inicio 
																	GROUP BY Ms.IdCuenta );

END
GO

/*
DECLARE @saldo_actual DECIMAL (18, 2);
DECLARE @saldo_anterior DECIMAL (18, 2);

EXECUTE SaldosDeCuentaCliente 1, '2018-01-01', '2019-12-12', @saldo_anterior OUTPUT, @saldo_actual OUTPUT;
PRINT 'Saldo actual: '+ CAST (@saldo_actual AS VARCHAR (255)) + ' - Saldo anterior: ' + CAST (@saldo_anterior AS VARCHAR (255));

GO
*/



/* Agregar la columna 'SaldoCuenta' en la tabla 'Cuenta'
 --ALTER TABLE Cuenta ADD SaldoCuenta DECIMAL(18, 2);*/
 
 --(1)(b)
 /*generarSaldos*/
CREATE PROCEDURE generarSaldos
@cuenta INT /* Cuenta a generar saldo. */
AS BEGIN
	DECLARE @saldo_total DECIMAL (18, 2) = 0;

	SET @saldo_total = ( SELECT SUM (Me.ImporteMovim)
						FROM Movimiento Me 
							WHERE 
								Me.TipoMovim = 'E' 
								AND	Me.IdCuenta = @cuenta 
							GROUP BY Me.IdCuenta ) - (SELECT SUM (Ms.ImporteMovim) 
														FROM Movimiento Ms 
															WHERE 
																Ms.TipoMovim <> 'E' 
																AND Ms.IdCuenta = @cuenta 
															GROUP BY Ms.IdCuenta);

	UPDATE Cuenta SET SaldoCuenta = @saldo_total WHERE IdCuenta = @cuenta;
END
 
GO

