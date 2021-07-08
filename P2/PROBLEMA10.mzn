include "globals.mzn";
% Ejercicio 10

%Vamos a declarar las variables para este problema

%Vector para saber si hemos escogido un objeto o no de entre los 12 posible (1 si lo hemos escogido y 0 en caso contrario)
array[1..12] of var 0..1: escogido;

%Vector con los nombres de los 12 nom_obj que queremos llevar al viaje
array[1..12] of string: nom_obj = ["Mapa", "Cuchillo", "Prismáticos", "Agua", "Linterna", "Cerveza", "Novela", "Manual de Supervivencia", "Plátanos", "Caramelos", "Cerillas", "Espejo", ];

%Arrays con las preferencias y los pesos para cada objeto del vector anterior respectivamente
array[1..12] of int: preferencia = [100,90,75,95,85,10,5,70,90,20,50,40]; %por ejemplo, al mapa le corresponde el 100 o al cuchillo 90                                   
array[1..12] of int: peso = [50,500,1000,3000,1500,3000,500,1000,2000,500,250,500]; %por ejemplo, al mapa le corresponden 50g o al cuchillo 500g 

%Variables que almacenan las sumatorias de las preferencias y los pesos de cada objeto
var int: sumatoria_prefer; 
var int: sumatoria_pesos; 

%Hacemos las sumatorias de las preferencias y los pesos de entre los 12 objetos los que se han seleccionado (los que tienen valor 1)
%Para el peso ademas tenemos la restriccion de no poder exceder los 5kgs o 5000g en nuestro caso
constraint (sumatoria_prefer = sum(i in 1..12 where escogido[i] == 1)(preferencia[i]));
constraint (sumatoria_pesos = sum(i in 1..12 where escogido[i] == 1)(peso[i]) /\ sumatoria_pesos <= 5000);

%Satisfacemos las restricciones y por tanto resolvemos el problema maximizando la sumatoria de preferencias
solve maximize sumatoria_prefer;

%Mostramos por pantalla los valores del vector correspondientes para nuestra suma 
output ["Objetos ="];
output [" \(nom_obj[i])" | i in 1..12];
output [" | Preferencias = \(sumatoria_prefer) | PesoFinal = \(sumatoria_pesos) kgs"];