include "globals.mzn";
%Ejercicio 4

%Vamos a declarar las variables para este problema

%Variables que representan los rangos de valores para los 7 dias de la semana y los 7 amigos que se reunen 
set of int: num_dias = 1..7;
set of int: num_amigos = 1..7;

%Vector con los nombres de los siete dias de la semana
array [num_dias] of string: dias_semana=["LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"];
%Vector con los nombres de los siete amigos que se reunen 
array [num_amigos] of string: personas=["JUAN", "MARIA", "CARMEN", "FRANCISCO", "MARTA", "OLGA", "PEPE"];
%Vector en la que cada posicion representa a un amigo y el valor determina si ha dicho una verdad (1) o una mentira (0)
array [num_amigos] of var valor_afirmacion: afirm_amigos;  


%Representamos la verdad o mentira de las afirmaciones de cada amigo con el valor 1 o 0 respectivamente 
set of int: valor_afirmacion = 0..1;
%Variable que almacena el numero de afirm_amigos que se han dado tras evaluar las afirmaciones de los siete amigos
var int: num_V;
%Variable que representa un dia en concreto de los 7 posibles
var num_dias: dia;

%Como cada amigo dice una cosa, tenemos que diferenciar cada caso para asi obtener el dia de hoy y quien ha sido la persona que lo ha dicho, asi pues...
%Para el lunes => Maria y Pepe no mienten pero si el dia de hoy no es lunes, Maria si que miente
constraint (dia == 1 /\ afirm_amigos[2] == 1 /\ afirm_amigos[7] == 1 ) \/ (dia != 1 /\ afirm_amigos[2] == 0 );
%Para el martes => Juan y Pepe no mienten pero si el dia de hoy no es martes, Juan si que miente
constraint (dia == 2 /\ afirm_amigos[1] == 1 /\ afirm_amigos[7] == 1 ) \/ (dia != 2 /\ afirm_amigos[1] == 0 );
%Para el miercoles => Carmen y Pepe no mienten pero si el dia de hoy no es miercoles, Carmen si que miente
constraint (dia == 3 /\ afirm_amigos[3] == 1 /\ afirm_amigos[7] == 1 ) \/ (dia != 3 /\ afirm_amigos[3] == 0 );
%Para el jueves o viernes => Marta y Pepe no mienten pero si el dia de hoy no es ni jueves ni viernes, Marta si que miente
constraint ((dia == 4  \/ dia == 5) /\ afirm_amigos[5] ==1 /\ afirm_amigos[7] ==1) \/ ((dia != 4  /\ dia != 5) /\ afirm_amigos[5] ==0);
%Para el sabado => Pepe no miente o bien no es sabado y Pepe ni dice la verdad ni miente
constraint (dia == 6 /\ afirm_amigos[7] ==1  ) \/ (dia != 6);
%Para el domingo => Olga, Francisco y Pepe no mienten pero si el dia de hoy no es domingo mienten los tres
constraint (dia == 7 /\ afirm_amigos[4] ==1 /\ afirm_amigos[6] ==1 /\ afirm_amigos[7] == 0 ) \/ (dia != 7 /\ afirm_amigos[7] == 1 /\ afirm_amigos[4] ==0 /\ afirm_amigos[6] ==0);

%Cuando ya sabemos quien ha dicho la verdad, vamos a guardar en la variable correspondiente el numero de veces que se ha encontrado una verdad
num_V = sum([1 | j in num_amigos where afirm_amigos[j] == 1]);

%Satisfacemos las restricciones y por tanto resolvemos el problema minimizando el numero de verdades que se han encontrado
solve minimize num_V ;

%Mostramos por pantalla la persona que ha dicho que dia es hoy asi como el propio dia 
output [if fix(dia == i) then
          "hoy: \(dias_semana[i]) \n"
       else 
           "" 
       endif | i in num_dias] ++
       [ if fix(afirm_amigos[i]) == 1 then
           "emisor: \(personas[i]) \n"
       else
           ""
       endif | i in num_amigos];