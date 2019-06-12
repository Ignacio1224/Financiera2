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
    DECLARE @saldo DECIMAL (18, 2) = ISNULL ( (SELECT SUM(M.ImporteMovim)
												FROM Movimiento M
												WHERE 
													M.IdCuenta = @cuenta
													AND M.TipoMovim = 'E'
													AND M.FchMovim <= @fecha), 0) - ISNULL( (SELECT SUM(M.ImporteMovim)
																							  FROM Movimiento M
																							  WHERE 
																							   	M.IdCuenta = @cuenta
																								AND M.TipoMovim <> 'E'
																								AND M.FchMovim <= @fecha), 0);

    RETURN @saldo;
END
GO

--(1)(d)
/* maximoSaldoCliente */
CREATE FUNCTION maximoSaldoCliente (@cliente INT, @moneda INT)
RETURNS DECIMAL (18, 2)
AS BEGIN
	-- Hallamos la cuenta del cliente con dicha moneda
	DECLARE @id_cuenta INT = (SELECT C.IdCuenta FROM Cuenta C WHERE C.IdCliente = @cliente AND C.IdMoneda = @moneda);
		
	DECLARE @saldo_maximo DECIMAL(18,2) = 0;
	DECLARE @saldo_aux DECIMAL (18,2) = 0;
	DECLARE @importe_aux DECIMAL(18,2);
	DECLARE @tipo_movim_aux CHAR(1);
	DECLARE @index_ INT = 1;

	--Creamos una tabla temporal auxiliar (pero con un atributo identity, para usar como Index a la hora de recorrer).
	DECLARE @tabla_temp TABLE (
	idx INT IDENTITY(1,1), 
	IdMovim INT, 
	FchMovim DATE, 
	TipoMovim CHAR(1), 
	IdCuenta INT, 
	ImporteMovim DECIMAL(18,2))

	--Duplicamos la información que precisamos de la tabla movimiento.
	INSERT INTO @tabla_temp SELECT * FROM Movimiento M WHERE M.IdCuenta = @id_cuenta AND YEAR(M.FchMovim) = YEAR(GETDATE());

	WHILE (@index_  <= (SELECT COUNT(*) FROM @tabla_temp))
	BEGIN 
		SET @importe_aux = (SELECT t.ImporteMovim FROM @tabla_temp AS t WHERE t.idx = @index_);
		SET @tipo_movim_aux =  (SELECT t.TipoMovim FROM @tabla_temp AS t WHERE t.idx = @index_);
		
		IF( @tipo_movim_aux = 'E')
			BEGIN
				SET @saldo_aux += @importe_aux;
			END

		IF( @tipo_movim_aux = 'S' OR @tipo_movim_aux = 'T' )
			BEGIN
				SET @saldo_aux -= @importe_aux;  
			END 

		IF( @saldo_aux > @saldo_maximo)
			BEGIN
				SET @saldo_maximo = @saldo_aux;
			END
		SET @index_ = (@index_ + 1);
	END

RETURN @saldo_maximo;	
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
					

					DECLARE @sobregiro DECIMAL (18, 2) = ISNULL( (SELECT SUM (Me.ImporteMovim)
																	FROM Movimiento Me, Cuenta C, Moneda M 
																	WHERE 
																		Me.TipoMovim = 'E' 
																		AND	Me.IdCuenta = C.IdCliente
																		AND C.IdCliente = @id_cliente 
																		AND C.IdMoneda = M.IdMoneda
																		AND M.SimboloMoneda = 'US$'
																	GROUP BY Me.IdCuenta), 0) - ISNULL( (SELECT SUM (Ms.ImporteMovim) 
																										 FROM Movimiento Ms, Cuenta C, Moneda M
																									 	 WHERE 
																											Ms.TipoMovim <> 'E' 
																											AND	Ms.IdCuenta = C.IdCliente
																											AND C.IdCliente = @id_cliente 
																											AND C.IdMoneda = M.IdMoneda
																											AND M.SimboloMoneda = 'US$'
																										 GROUP BY Ms.IdCuenta), 0);

					-- Nombre del cliente.
					DECLARE @nom_cli VARCHAR (255) = (SELECT NombreCliente FROM Cliente WHERE IdCliente = @id_cliente);

					-- Si posee saldo > 0 no tiene sobregiro la cuenta.
					IF (@sobregiro > 0)
						BEGIN
							SET @salida = 'Cliente: ' + @nom_cli + ', no posee sobregiro al día de hoy.';
						END
					--
					ELSE
						--El sobregiro solo existe cuando la resta de las entradas y las salidas da números negativos.
						BEGIN
							SET @salida = 'Cliente: ' + CONVERT(VARCHAR(200),@nom_cli) + ', Sobregiro actual: '+ CONVERT(VARCHAR(200),ABS(@sobregiro)) +' US$';
						END
				END
			--
			ELSE
				BEGIN
					SET @salida = 'El cliente ID['+ CONVERT(VARCHAR(200),@id_cliente)+'] no posee cuenta en dólares.';
				END
	END
	--
	ELSE
		BEGIN
			SET @salida = 'El cliente ingresado no existe.';
		END	

	--Retorno final
	RETURN @salida;

END
GO
