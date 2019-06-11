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
	DECLARE @entradas_act DECIMAL (18, 2) = (	SELECT SUM (Me.ImporteMovim)
												FROM Movimiento Me 
												WHERE 
													Me.TipoMovim = 'E' 
													AND Me.IdCuenta = @cuenta
													AND Me.FchMovim BETWEEN @fch_inicio AND @fch_fin
												GROUP BY Me.IdCuenta );

	DECLARE @no_entradas_act DECIMAL (18, 2) = (	SELECT SUM (Ms.ImporteMovim) 
													FROM Movimiento Ms 
													WHERE 
														Ms.TipoMovim <> 'E' 
														AND Ms.IdCuenta = @cuenta

														AND Ms.FchMovim BETWEEN @fch_inicio AND @fch_fin 
													GROUP BY Ms.IdCuenta
													  );

	DECLARE @entradas_ant DECIMAL (18, 2) = (	SELECT SUM (Me.ImporteMovim) 
												FROM Movimiento Me 
												WHERE
													Me.TipoMovim = 'E' 
													AND Me.IdCuenta = @cuenta 
													AND Me.FchMovim BETWEEN -53690 AND @fch_inicio 
												GROUP BY Me.IdCuenta );
	
	DECLARE @no_entradas_ant DECIMAL (18, 2) = (	SELECT SUM (Ms.ImporteMovim) 
													FROM Movimiento Ms 
													WHERE 
														Ms.TipoMovim <> 'E' 
														AND Ms.IdCuenta = @cuenta
														AND Ms.FchMovim BETWEEN -53690 AND @fch_inicio 
													GROUP BY Ms.IdCuenta );


	SET @saldo_actual  = ISNULL(@entradas_act, 0) - ISNULL(@no_entradas_act, 0);
							
	SET @saldo_anterior = ISNULL(@entradas_ant, 0) - ISNULL(@no_entradas_ant, 0);

END
GO


/* Agregar la columna 'SaldoCuenta' en la tabla 'Cuenta'
 --ALTER TABLE Cuenta ADD SaldoCuenta DECIMAL(18, 2);*/
 
 --(1)(b)
 /*generarSaldos*/
CREATE PROCEDURE generarSaldos
	@cuenta INT /* Cuenta a generar saldo. */
AS BEGIN
	DECLARE @saldo_total DECIMAL (18, 2) = 0;

	DECLARE @entrada DECIMAL (18, 2) = ( SELECT SUM (Me.ImporteMovim)
						FROM Movimiento Me 
							WHERE 
								Me.TipoMovim = 'E' 
								AND	Me.IdCuenta = @cuenta 
							GROUP BY Me.IdCuenta );

	DECLARE @no_entrada DECIMAL (18, 2) = (	SELECT SUM (Ms.ImporteMovim) 
														FROM Movimiento Ms 
															WHERE 
																Ms.TipoMovim <> 'E' 
																AND Ms.IdCuenta = @cuenta
															GROUP BY Ms.IdCuenta);

	SET @saldo_total = ISNULL(@entrada, 0) - ISNULL(@no_entrada, 0);

	UPDATE Cuenta SET SaldoCuenta = @saldo_total WHERE IdCuenta = @cuenta;
END
 
GO
