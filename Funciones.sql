/* Funciones */

/* Autor: Ignacio Cabrera - Santiago Manzoni */

/* NOTA: Se asume que el año corriente es el actual. */


USE OBLBD2;
GO

--(1)(c)
/* verSaldoCuenta */
CREATE FUNCTION verSaldoCuenta (@cuenta INT, @fecha DATE)
    RETURNS DECIMAL (18, 2)
AS BEGIN
    DECLARE @saldo DECIMAL (18, 2) = ( 	SELECT SUM(M.ImporteMovim)
										FROM Movimiento M
										WHERE 
											M.IdCuenta = @cuenta
											AND M.TipoMovim = 'E'
											AND M.FchMovim <= @fecha ) - (	SELECT SUM(M.ImporteMovim)
																			FROM Movimiento M
																			WHERE 
																				M.IdCuenta = @cuenta
																				AND M.TipoMovim <> 'E'
																				AND M.FchMovim <= @fecha);

    RETURN @saldo;
END
GO

--(1)(d)
/* maximoSaldoCliente */
CREATE FUNCTION maximoSaldoCliente (@cliente INT, @moneda INT)
    RETURNS DECIMAL (18, 2)
AS BEGIN
    DECLARE @saldo DECIMAL (18, 2) = (	SELECT SUM(Mov.ImporteMovim) 
										FROM 
											Movimiento Mov
											JOIN Cuenta Cu ON Cu.IdCuenta = Mov.IdCuenta
											JOIN Cliente Cli ON Cli.IdCliente = Cu.IdCliente
										WHERE 
											Cli.IdCliente = @cliente
											AND Cu.IdMoneda = @moneda
											AND Mov.TipoMovim = 'E'
											AND YEAR (Mov.FchMovim) = YEAR (GETDATE ())
										GROUP BY Mov.IdCuenta) - (	SELECT SUM(Mov.ImporteMovim) 
																	FROM 
																		Movimiento Mov
																		JOIN Cuenta Cu ON Cu.IdCuenta = Mov.IdCuenta
																		JOIN Cliente Cli ON Cli.IdCliente = Cu.IdCliente
																	WHERE 
																		Cli.IdCliente = @cliente
																		AND Cu.IdMoneda = @moneda
																		AND Mov.TipoMovim <> 'E'
																		AND YEAR (Mov.FchMovim) = YEAR (GETDATE ())
																	GROUP BY Mov.IdCuenta);

    RETURN @saldo;
END
GO

--(1)(e)
/* sobregiroClienteUSD */
CREATE FUNCTION sobregiroClienteUSD (@id_cliente INT) 
	RETURNS VARCHAR(255)
AS BEGIN
	DECLARE @salida VARCHAR(255);

	--Si existe el cliente
	IF EXISTS(Select 1 FROM Cliente WHERE IdCliente = @id_cliente)
		BEGIN
			--Si el cliente tiene cuenta en dolares
			IF EXISTS( 	SELECT 1 
						FROM Cliente Cli 
							JOIN Cuenta Cu ON Cli.IdCliente = Cu.IdCliente 
							JOIN Moneda M on M.IdMoneda = Cu.IdMoneda 
						WHERE M.SimboloMoneda = 'U$D'
					)
				BEGIN
					DECLARE @sobregiro DECIMAL (18, 2);

					SET @sobregiro = (SELECT SUM (Me.ImporteMovim)
										FROM Movimiento Me, Cuenta C, Moneda M 
											WHERE 
												Me.TipoMovim = 'E' 
												AND	Me.IdCuenta = C.IdCliente
												AND C.IdCliente = @id_cliente 
												AND C.IdMoneda = M.IdMoneda
												AND M.SimboloMoneda = 'U$D'
											GROUP BY Me.IdCuenta) - (	SELECT SUM (Ms.ImporteMovim) 
																		FROM Movimiento Ms, Cuenta C, Moneda M
																		WHERE 
																			Ms.TipoMovim <> 'E' 
																			AND	Ms.IdCuenta = C.IdCliente
																			AND C.IdCliente = @id_cliente 
																			AND C.IdMoneda = M.IdMoneda
																			AND M.SimboloMoneda = 'U$D'
																		GROUP BY Ms.IdCuenta);

					-- Nombre del cliente.
					DECLARE @nom_cli VARCHAR (255) = (SELECT NombreCliente FROM Cliente WHERE IdCliente = @id_cliente);

					-- Si posee saldo > 0 no tiene sobregiro la cuenta.
					IF (@sobregiro > 0)
						BEGIN
							SET @salida = 'Cliente: ' + @nom_cli + ', NO POSEE SOBREGIRO AL DÍA DE HOY.';
						END
					ELSE
						--El sobregiro solo existe cuando la resta de las entradas y las salidas da números negativos.
						BEGIN
							SET @salida = 'Cliente: ' + @nom_cli + ', Sobregiro actual: '+ ABS(@sobregiro) +' U$D';
						END
				END
		
			ELSE
				BEGIN
					SET @salida = 'El cliente no posee cuenta en dólares.';
				END
	END

	ELSE
		BEGIN
			SET @salida = 'El cliente ingresado no existe.';
		END	

	--Retorno final
	RETURN @salida;

END
GO
