/* Vistas */
/*
    Autor: Ignacio Cabrera - Santiago Manzoni
*/

/*
    NOTA: Se asume que el año corriente es el actual.
*/



USE OBLBD2;
GO



/* Cantidad_Depositos_Por_Mes */
CREATE VIEW Cantidad_Depositos_Por_Mes
AS
    (
    SELECT *
    FROM Moneda
);



/* Resumen_Movimiento_Cliente */
CREATE VIEW Resumen_Movimiento_Cliente
AS
    (
    SELECT *
    FROM Moneda
);
