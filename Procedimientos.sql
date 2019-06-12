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
	SET @saldo_actual  = ISNULL((SELECT SUM (Me.ImporteMovim)
									FROM Movimiento Me 
									WHERE 
										Me.TipoMovim = 'E' 
										AND Me.IdCuenta = @cuenta
										AND Me.FchMovim BETWEEN @fch_inicio AND @fch_fin
									GROUP BY Me.IdCuenta), 0 ) - ISNULL( (SELECT SUM (Ms.ImporteMovim) 
																			FROM Movimiento Ms 
																			WHERE 
																				Ms.TipoMovim <> 'E' 
																				AND Ms.IdCuenta = @cuenta
																				AND Ms.FchMovim BETWEEN @fch_inicio AND @fch_fin 
																			GROUP BY Ms.IdCuenta) , 0);



	SET @saldo_anterior = ISNULL( (SELECT SUM(Me.ImporteMovim) 
									FROM Movimiento Me 
									WHERE
										Me.TipoMovim = 'E' 
										AND Me.IdCuenta = @cuenta 
										AND Me.FchMovim < @fch_inicio 
									GROUP BY Me.IdCuenta) , 0 ) - ISNULL( (SELECT SUM (Ms.ImporteMovim) 
																			FROM Movimiento Ms 
																			WHERE 
																				Ms.TipoMovim <> 'E' 
																				AND Ms.IdCuenta = @cuenta
																				AND Ms.FchMovim < @fch_inicio 
																			GROUP BY Ms.IdCuenta) , 0 );
END
GO


/* Agregar la columna 'SaldoCuenta' en la tabla 'Cuenta'
 --ALTER TABLE Cuenta ADD SaldoCuenta DECIMAL(18, 2);*/
 
 --(1)(b)
 /*generarSaldos*/
CREATE PROCEDURE generarSaldos
	@cuenta INT /* Cuenta a generar saldo. */
AS BEGIN
	
	DECLARE @saldo DECIMAL (18, 2) = ISNULL((SELECT SUM(Me.ImporteMovim)
											FROM Movimiento Me 
											WHERE 
												Me.TipoMovim = 'E' 
												AND	Me.IdCuenta = @cuenta 
											GROUP BY Me.IdCuenta ), 0) - ISNULL((SELECT SUM(Ms.ImporteMovim) 
																				FROM Movimiento Ms 
																				WHERE 
																					Ms.TipoMovim <> 'E' 
																					AND Ms.IdCuenta = @cuenta
																				GROUP BY Ms.IdCuenta), 0);

	UPDATE Cuenta SET SaldoCuenta = @saldo WHERE IdCuenta = @cuenta;
END
GO
