/* Para esta evaluación usaremos la BBDD de northwind con la que ya estamos familiarizadas de los ejercicios de pair programming. 
En esta evaluación tendréis que contestar a las siguientes preguntas:*/

USE northwind;

/*1. Selecciona todos los campos de los productos, que pertenezcan a los proveedores con códigos: 1, 3, 7, 8 y 9, que tengan stock en el almacén, 
y al mismo tiempo que sus precios unitarios estén entre 50 y 100. 
Por último, ordena los resultados por código de proveedor de forma ascendente.*/

SELECT *
FROM products
WHERE supplier_id IN (1, 3, 7, 8, 9)
AND units_in_stock >= 1
AND unit_price BETWEEN 50 AND 100
ORDER BY supplier_id
;

/*2. Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6, 
además que hayan vendido a clientes que tengan códigos que comiencen con las letras de la A hasta la G.
Por último, en esta búsqueda queremos filtrar solo por aquellos envíos que la fecha de pedido esté comprendida 
entre el 22 y el 31 de Diciembre de cualquier año.*/

SELECT employees.first_name, employees.last_name, employees.employee_id, orders.customer_id, orders.shipped_date
FROM employees
INNER JOIN orders
ON employees.employee_id = orders.employee_id
WHERE employees.employee_id BETWEEN 3 AND 6
AND orders.customer_id REGEXP '^[A-G]'
AND orders.shipped_date  REGEXP '^[0-9]{4}-12-(2[2-9]|3[0-1])'
;

/*3. Calcula el precio de venta de cada pedido una vez aplicado el descuento. Muestra el id del la orden, el id del producto, 
el nombre del producto, el precio unitario, la cantidad, el descuento y el precio de venta después de haber aplicado 
el descuento.*/

SELECT order_details.order_id, order_details.product_id, products.product_name, order_details.unit_price, order_details.quantity, 
order_details.discount, SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS precio_rebajado
FROM order_details
INNER JOIN products
ON order_details.product_id = products.product_id 
GROUP BY order_details.order_id, order_details.product_id, products.product_name, order_details.unit_price, order_details.quantity, order_details.discount
 ;
/*Para calcular el descuento en el pedido, necesito un group by para agrupar todos los productos que pertenecen a ese pedido 
y que le aplique el descuento al producto que lo tenga y según la cantidad que se haya solicitado para ese pedido. 
Para realizar esta operación, debemos multiplicar el precio de cada unidad por la cantidad cuyo resultado se multiplica por la obtención de 1 menos el descuento asignado. 
Ese 1 hace referencia a que 100 entre 100 es igual a 1. Por tanto, restamos 1 menos lo que sea de descuento y eso es lo que multiplicamos a lo anterior 
para obtener el precio final rebajado.*/


/*4. Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio 
medio total de los productos de la BBDD.*/
/*¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos?*/

SELECT DISTINCT orders.employee_id, products.product_id, products.unit_price, order_details.quantity
FROM products
INNER JOIN order_details
ON order_details.product_id = products.product_id
INNER JOIN orders
ON orders.order_id = order_details.order_id
WHERE products.unit_price > (SELECT AVG(unit_price)
FROM products);

/*Para tener la columna de employee_id en la query, hemos tenido que hacer dos inner joins 
porque no hay una tabla que contenga employee_id que se pueda enlazar directamente con products. 
Entonces, hemos hecho primero un inner join con la tabla order_details, relacionando product_id de la tabla products y de la tabla order_details
(ASÍ TB AÑADIMOS QUANTITY DE ORDER_DETAILS)
Después, hemos creaado un inner join para relacionar order_details con orders a partir de order_id y así poder visualizar la columna de employee_id de la tabla orders 
en la query*/

/*5. Basándonos en la query anterior, ¿qué empleado es el que vende más productos? Soluciona este ejercicio con una subquery
BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/

SELECT employee_id, SUM(quantity)
FROM (
	SELECT DISTINCT orders.employee_id, order_details.quantity
	FROM products
	INNER JOIN order_details
	ON order_details.product_id = products.product_id
	INNER JOIN orders
	ON orders.order_id = order_details.order_id
	WHERE products.unit_price > (
		SELECT AVG(unit_price)
		FROM products
	)
) AS relacion
GROUP BY employee_id
ORDER BY 2 DESC
;

/* Hemos sumado quantity y lo hemos agrupado por employee_id para que sume la cantidad de todos los productos vendidos por cada empleado*/
/*EL 2 después de order by hace referencia a que queremos que ordene la segunda columna*/

