include "globals.mzn";
%Ejercicio 2 

%Vamos a declarar las variables para este problema

%Vector que almacena en cada posicion un tipo de moneda diferente, es decir, en la primera poisicion del vector tenemos las monedas de 1 centimo,
%en la segunda posicion del vector tenemos las monedas de 2 centimos, etc.
set of int: cant_monedas = 0..7; %Son 8 monedas diferentes en total
array [cant_monedas] of var int: monedas;

%Hay que tener 0 o mas monedas de cada tipo
constraint forall(i in cant_monedas)(monedas[i]>=0);

%Restriccion --> NO podemos exceder el importe de 7.99 euros o 799 centimos en este caso
%La suma de la cantidad de monedas que haya de cada tipo mutliplicadas por sus respectivos valores tiene que ser igual a 799 centimos
constraint monedas[0] + 2 * monedas[1] + 5 * monedas[2] + 10 * monedas[3] + 20 * monedas[4] + 50 * monedas[5] + 100 * monedas[6] + 200 * monedas[7] == 799;
           
%Satisfacemos las restricciones y por tanto resolvemos el problema minimizando el numero total de monedas utilizadas
solve minimize monedas[0]+monedas[1]+monedas[2]+monedas[3]+monedas[4]+monedas[5]+monedas[6]+monedas[7];

%Mostramos por pantalla la cantidad de cada tipo de moneda y el total de monedas necesarias para alcanzar 7.99 euros
output ["monedas: [\(monedas[0]) \(monedas[1]) \(monedas[2]) \(monedas[3]) \(monedas[4]) \(monedas[5]) \(monedas[6]) \(monedas[7]) ]\n"];
output ["total monedas: \(monedas[0]+monedas[1]+monedas[2]+monedas[3]+monedas[4]+monedas[5]+monedas[6]+monedas[7])\n"];
