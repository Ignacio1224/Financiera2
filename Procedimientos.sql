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
    SELECT @cuenta, @fch_inicio
END
GO



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
