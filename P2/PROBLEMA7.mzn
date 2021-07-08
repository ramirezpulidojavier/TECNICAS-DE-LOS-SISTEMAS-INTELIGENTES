include "globals.mzn";
%Ejercicio 7

%Vamos a declarar las variables para este problema

%Vectores con las 12 tareas de la construccion del avion y sus duraciones respectivamente (e.g Tarea A tiene una duracion de 60, la B de 10...)
array[1..12] of string: tareas = ["A","B","C","D","E","F","G","H","I","J","K","L"]; 
array[1..12] of int: duraciones = [60,10,5,5,5,2,7,3,7,2,5,1];

%Variable para conocer la maxima duracion posible, es decir, la suma de las duraciones de cada tarea
int: duracion_maxima = sum(duraciones);

%Variable para saber la minima duracion de la construccion del avion 
var 1..duracion_maxima: duracion_minima;


% Matriz que indica para cada tarea cuál es su predecesora. 
% Tenemos 15 filas ya que son 15 las restricciones de precedencia que se nos presentan 
% Y 2 columnas que ya que queremos indicar la tarea y su predecesora, por ejemplo:
% [1,2] quiere decir que la tarea A ha debido fin_tareaalizar para que pueda ejecutarse la tarea B

%Mediante una matriz vamos a representar las tareas predecesoras a cada una de las tareas
%En total tenemos 15 restricciones de precedencia y un ejemplo de precedencia de esta matriz seria el 3,8 que indica que la tarea C tiene que darse antes que la tarea H
array[1..15, 1..2] of int: precedencias = [| 1,2 | 2,3 | 3,4 | 4,5 | 4,6 | 4,7 | 5,7 | 3,8 | 5,9 | 6,9 | 5,10 | 6,10 | 9,11 | 10,11 | 11,12 |];

%Vector con los inicio_tareas y fin_tareaales de cada tarea
array[1..12] of var 1..duracion_maxima: inicio_tarea; 
array[1..12] of var 1..duracion_maxima: fin_tarea;

%El fin_tareaal de una tarea no es mas que la suma de su inicio_tarea y su duracion y no puede darse una tarea de una columna superior de la matriz antes que otra que se encuentre en una columna inferior. Es decir, nuestra matriz se rellena de la forma A,B | B,C... y no puede darse el caso en el que la tera A se ejecute despues que la tarea B (la duracion la tomamos como la suma de sus inicio_tareas y sus duraciones)
constraint maximum(duracion_minima, fin_tarea) /\ forall(i in 1..12) (fin_tarea[i] = inicio_tarea[i] + duraciones[i]) /\ forall(p in 1..15) (inicio_tarea[precedencias[p,1]] + duraciones[precedencias[p,1]] <= inicio_tarea[precedencias[p,2]]);

%Satisfacemos las restricciones y por tanto resolvemos el problema minimizando el tiempo de ejecucion de las tareas
solve minimize duracion_minima;

%Mostramos por pantalla el tiempo minimo de la construccion del avion y los valores de inicio_tarea para cada tarea
output["TIEMPO MINIMO = \(duracion_minima)\n"];
output["La tarea \(tareas[i]) empieza en tiempo \(inicio_tarea[i])\n" | i in 1..12];

