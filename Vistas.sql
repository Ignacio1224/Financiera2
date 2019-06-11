/* Vistas */

/* Autor: Ignacio Cabrera - Santiago Manzoni */

/* NOTA: Se asume que el año corriente es el actual. */



USE OBLBD2;
GO


/* Cantidad_Depositos_Por_Mes */
CREATE VIEW Cantidad_Depositos_Por_Mes
AS (
    SELECT MONTH (M.FchMovim) AS Mes, COUNT (*) AS Cant_Depo
	FROM Movimiento M
	WHERE
		YEAR(M.FchMovim) = YEAR(GETDATE())
		AND M.TipoMovim = 'E'
	GROUP BY MONTH(M.FchMovim)
);
GO


/* Resumen_Movimiento_Cliente */
CREATE VIEW Resumen_Movimiento_Cliente
AS(
	SELECT Cli.IdCliente, Cli.NombreCliente, Mov.TipoMovim, COUNT(Mov.IdMovim) AS Cant_Movimientos, (	SELECT M.FchMovim FROM Movimiento M 
																										WHERE 
																											M.IdCuenta = Mov.IdCuenta
																											AND M.Tipomovim = Mov.TipoMovim 
																											AND M.FchMovim >= ALL (	SELECT Mf.FchMovim 
																																	FROM Movimiento Mf
																																	WHERE 
																																		Mf.IdCuenta = Mov.IdCuenta
																																		AND Mf.TipoMovim = Mov.TipoMovim
																																	)
																									) AS Ultimo_Movim 
	FROM Cliente Cli																					
		JOIN Cuenta C ON C.IdCliente = Cli.IdCliente
		JOIN Movimiento Mov ON Mov.IdCuenta = C.IdCuenta
	GROUP BY Mov.IdCuenta, Cli.IdCliente, Cli.NombreCliente, Mov.TipoMovim
);
GO
