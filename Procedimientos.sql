/* Procedimientos Almacenados */
/*
    Autor: Ignacio Cabrera - Santiago Manzoni
*/

/*
    NOTA: Se asume que el año corriente es el actual.
*/



USE OBLBD2;
GO

/* SaldosDeCuentaCliente */
CREATE PROCEDURE SaldosDeCuentaCliente
    @cuenta INT = 0, /* Numero de cuenta a evaluar */
    @fch_inicio DATE = GETDATE, /* Fecha de inicio de la evaluación */
    @fch_fin DATE = GETDATE, /*  Fecha de fin de la evaluación */
    @saldo_anterior DECIMAL (18, 2) = 0 OUTPUT, /* Saldo anterior a la fecha de fin */
    @saldo_actual DECIMAL (18, 2) = 0 OUTPUT /* Saldo actual a la fecha de fin */
AS BEGIN

	DECLARE @ent_act DECIMAL (18, 2) = 0;
	DECLARE @sal_act DECIMAL (18, 2) = 0;
	DECLARE @ent_ant DECIMAL (18, 2) = 0;
	DECLARE @sal_ant DECIMAL (18, 2) = 0;

	SELECT @ent_act = SUM (Me.ImporteMovim)
	FROM Movimiento Me 
	WHERE 
		Me.TipoMovim = 'E' 
		AND Me.IdCuenta = @cuenta 
		AND Me.FchMovim BETWEEN @fch_inicio AND @fch_fin
	GROUP BY Me.IdCuenta;
	
	SELECT @sal_act = SUM (Ms.ImporteMovim) 
	FROM Movimiento Ms 
	WHERE 
		Ms.TipoMovim <> 'E' 
		AND Ms.IdCuenta = @cuenta 
		AND Ms.FchMovim BETWEEN @fch_inicio AND @fch_fin 
	GROUP BY Ms.IdCuenta;

	SELECT @ent_ant = SUM (Me.ImporteMovim) 
	FROM Movimiento Me 
	WHERE
		Me.TipoMovim = 'E' 
		AND Me.IdCuenta = @cuenta 
		AND Me.FchMovim BETWEEN -53690 AND @fch_inicio 
	GROUP BY Me.IdCuenta;
	
	SELECT @sal_ant = SUM (Ms.ImporteMovim) 
	FROM Movimiento Ms 
	WHERE 
		Ms.TipoMovim <> 'E' 
		AND Ms.IdCuenta = @cuenta
		AND Ms.FchMovim BETWEEN -53690 AND @fch_inicio 
	GROUP BY Ms.IdCuenta;

	SET @saldo_actual = @ent_act - @sal_act;
	SET @saldo_anterior = @ent_ant - @sal_ant;

END
GO

DECLARE @saldo_actual DECIMAL (18, 2);
DECLARE @saldo_anterior DECIMAL (18, 2);

EXECUTE SaldosDeCuentaCliente 1, '2018-01-01', '2019-12-12', @saldo_anterior OUTPUT, @saldo_actual OUTPUT;
PRINT 'Saldo actual: '+ CAST (@saldo_actual AS VARCHAR (255)) + ' - Saldo anterior: ' + CAST (@saldo_anterior AS VARCHAR (255));


/* Agregar la columna 'SaldoCuenta' en la tabla 'CUENTAS' */
-- ALTER TABLE CUENTAS ADD SaldoCuenta DECIMAL(18, 2);
/* generarSaldos */
CREATE PROCEDURE generarSaldos
    @msj VARCHAR = 'Ha ocurrido un error' OUTPUT
AS BEGIN
    SELECT @msj
END
GO



/* sobregiroClienteUSD */
CREATE PROCEDURE sobregiroClienteUSD
    @id_cliente INT = 0,
    @nombre_cliente VARCHAR (255) = 'NULL' OUTPUT,
    @sobregiro DECIMAL (18, 2) = 0 OUTPUT
AS BEGIN
    SELECT @id_cliente;
END
GO
