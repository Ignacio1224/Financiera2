/* Funciones */
/*
    Autor: Ignacio Cabrera - Santiago Manzoni
*/

/*
    NOTA: Se asume que el año corriente es el actual.
*/



USE OBLBD2;
GO



/* verSaldoCuenta */
CREATE FUNCTION verSaldoCuenta (@cuenta INT, @fecha DATE)
    RETURNS DECIMAL (18, 2)
AS BEGIN
    DECLARE @saldo DECIMAL (18, 2) = 0;

    RETURN @saldo;
END
GO



/* maximoSaldoCliente */
CREATE FUNCTION maximoSaldoCliente (@cliente INT, @moneda INT)
    RETURNS DECIMAL (18, 2)
AS BEGIN
    DECLARE @saldo DECIMAL (18, 2) = 0;


    RETURN @saldo;
END
