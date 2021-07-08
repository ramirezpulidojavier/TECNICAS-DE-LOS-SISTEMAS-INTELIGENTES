include "globals.mzn";
%Ejercicio 6

%DECLARACION DE CONJUNTO DE VALORES
set of int: horas_disponibles = 1..6;             %Hay 6 horas diferentes (8, 9, 10, 11, 12, 13)
set of int: dias_disponibles  = 1..5;             %Hay 5 dias diferentes (lunes - viernes)
set of int: nombres_disponibles = 1..17;          %Es la cantidad de combinaciones (7 asig de 2 bloques, 2 asig de 1 bloque y el recreo)
set of int: asignaturas_disponibles = 1..10;      %Las 9 asignaturas y el recreo (NA)

%DECLARACION DE VECTORES DE DATOS
array[asignaturas_disponibles] of int: bloques_de = [2, 1, 2, 2, 2, 1, 1, 2, 1, 1];     %Horas por bloque de cada asignatura (NA cuenta como 1)
array[horas_disponibles, dias_disponibles] of var asignaturas_disponibles: matriz_asig; %Matriz de horasxdias que contiene el indice de la asig
array[horas_disponibles, dias_disponibles] of var 1..2: matriz_bloq;                   %Matriz de horasxdias que contiene el nº del bloque de asig

%DECLARACION DE VECTORES DE TEXTO PARA LA SALIDA
array[dias_disponibles ] of string: margen_superior  = ["    Lunes    ","    Martes    ","    Miercoles    ","    Jueves    ","    Viernes    "];
array[horas_disponibles] of string: margen_izquierdo = ["08:00-09:00","09:00-10:00","10:00-11:00","11:00-12:00","12:00-13:00","13:00-14:00"];
array[nombres_disponibles] of string:nombres_totales = ["A1-BLOQ1-PROF1","A1-BLOQ2-PROF1",
                                                        "A2-BLOQ1-PROF4","A2-BLOQ2-PROF4",
                                                        "A3-BLOQ1-PROF1","A3-BLOQ2-PROF1",
                                                        "A4-BLOQ1-PROF2","A4-BLOQ2-PROF2",
                                                        "A5-BLOQ1-PROF2","A5-BLOQ2-PROF2",
                                                        "A6-BLOQ1-PROF3","A6-BLOQ2-PROF3",
                                                        "A7-BLOQ1-PROF4","A7-BLOQ2-PROF4",
                                                        "A8-BLOQ1-PROF4","A9-BLOQ1-PROF3",
                                                        "      NA      "];


%RESTRICCIONES
%  d) En cada día de la semana solo se puede impartir, como máximo, un bloque de cada asignatura
constraint forall(dd in dias_disponibles, hd1 in horas_disponibles)(
              forall(hd2 in horas_disponibles)(
                     hd1 == hd2 \/                                      %O estoy comparando el mismo
                     matriz_asig[hd1, dd] != matriz_asig[hd2, dd] \/    %O se da otra asignatura
                     (matriz_asig[hd1, dd] == matriz_asig[hd2, dd] /\ matriz_bloq[hd1, dd] == matriz_bloq[hd2, dd]))); %Si es la misma asignatura
                                                                                                                       %en el mismo dia tiene que 
                                                                                                                       %ser el mismo bloque 
                                                                                                                       
                                                                                                                       
%  f) Cada profesor solo puede impartir un bloque de alguna de sus asignaturas cada día, excepto Prof4 (que puede impartir más de una).
constraint forall(dd in dias_disponibles, hd1 in horas_disponibles )(
               if matriz_asig[hd1,dd] == 3 then   %El profesor 1 da la asignatura 3
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 1)  %por lo que la 1 no puede darse en ninguna hora del mismo dia
               elseif matriz_asig[hd1,dd] == 1 then %El profesor 1 da la asignatura 1
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 3)  %por lo que la 3 no puede darse en ninguna hora del mismo dia
               elseif matriz_asig[hd1,dd] == 4 then %El profesor 2 da la asignatura 4
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 5)  %por lo que la 5 no puede darse en ninguna hora del mismo dia
               elseif matriz_asig[hd1,dd] == 5 then %El profesor 2 da la asignatura 5
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 4)  %por lo que la 4 no puede darse en ninguna hora del mismo dia
               elseif matriz_asig[hd1,dd] == 6 then %El profesor 3 da la asignatura 6
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 9)  %por lo que la 9 no puede darse en ninguna hora del mismo dia
               elseif matriz_asig[hd1,dd] == 9 then %El profesor 3 da la asignatura 9
                     forall(hd2 in horas_disponibles)(matriz_asig[hd2,dd] != 6)  %por lo que la 6 no puede darse en ninguna hora del mismo dia
               else (true)
               endif
);


%  g) La cuarta franja horaria debe reservarse para el recreo (“NA”); es decir, no asignar ninguna asignatura.
constraint forall(dd in dias_disponibles, hd in horas_disponibles)(
                  if hd == 4 then %Si es la cuarta hora
                      matriz_asig[hd, dd] == 10 /\ matriz_bloq[hd, dd] == 1  %tiene que ser recreo y el bloque 1
                  else            %Si no es la cuarta hora
                      matriz_asig[hd, dd] != 10   %no puede ser el recreo
                  endif
);

%  h) El orden de cada bloque es importante, el primer bloque de cada asignatura se posiciona en un día anterior que el segundo bloque
constraint forall(dd1 in dias_disponibles, hd1 in horas_disponibles)(  %Recorro la matriz de asignaturas
              %Tambien recorro la misma matriz pero examinando otros dias y horas que no sean el recreo 
              forall(dd2 in dias_disponibles, hd2 in horas_disponibles where hd1 != 4 /\ hd2 != 4 /\ dd2 != dd1 )(
                    %Si encuentro la misma asignatura en otro dia distinto al actual
                    if matriz_asig[hd1, dd1] == matriz_asig[hd2, dd2] then  
                          %O el dia es posterior y por tanto el bloque actual es el 1 y el otro el 2
                         (dd1 < dd2 /\ matriz_bloq[hd1, dd1] == 1 /\ matriz_bloq[hd2, dd2] == 2 ) \/  
                          %O el dia es anterior y por tanto el bloque actual es el 2 y el otro el 1
                         (dd1 > dd2 /\ matriz_bloq[hd1, dd1] == 2 /\ matriz_bloq[hd2, dd2] == 1 )
                    endif
));

%  i) Varios profesores tienen ciertas restricciones horarias: 
constraint forall(dd in dias_disponibles, hd in horas_disponibles)(
                  if matriz_asig[hd,dd] == 4 \/ matriz_asig[hd,dd] == 5 then hd < 3         %Profesor 2
                  elseif matriz_asig[hd,dd] == 1 \/ matriz_asig[hd,dd] == 3 then hd > 4     %Profesor 1
                  elseif matriz_asig[hd,dd] == 6 \/ matriz_asig[hd,dd] == 9 then hd == 3    %Profesor 3
                  else (true) endif
);

%  j) Varias asignaturas también deben ser impartidas ciertos días concretos de la semana:
constraint forall(dd in dias_disponibles, hd in horas_disponibles)(
                  %Asignaturas 1 y 4 tienen que tener un dia menor al 3 (miercoles), es decir, lunes o martes
                  if matriz_asig[hd,dd] == 1 \/ matriz_asig[hd,dd] == 4 then dd < 3                   %Asignatura 1 y 4
                  %Asignaturas 3 tiene que tener el dia 3 (miercoles) o 4 (jueves) 
                  elseif matriz_asig[hd,dd] == 3                        then dd == 3 \/ dd == 4       %Asignatura 3
                  %Asignaturas 5 tiene que tener un dia mayor al 3 (miercoles), es decir, jueves o viernes
                  elseif matriz_asig[hd,dd] == 5                        then dd > 3                   %Asignatura 5
                  %Asignaturas 6 tiene que tener el dia 3 (miercoles) o 5 (viernes) 
                  elseif matriz_asig[hd,dd] == 6                        then dd == 3 \/ dd == 5       %Asignatura 6
                  %Asignaturas 7 tiene que tener el dia 2 (martes) o 5 (viernes) 
                  elseif matriz_asig[hd,dd] == 7                        then dd == 2 \/ dd == 5       %Asignatura 7
                  %Asignaturas 8 tiene que tener el dia 3 (miercoles)
                  elseif matriz_asig[hd,dd] == 8                        then dd == 3                  %Asignatura 8
                  %Asignaturas 9 tiene que tener el dia 1 (lunes)
                  elseif matriz_asig[hd,dd] == 9                        then dd == 1                  %Asignatura 9
                  else (true) endif
);

%EXTRA PARA QUE NO HAYA MAS HORAS DIARIAS DE UNA ASIGNATURA DE LAS PERMITIDAS
constraint forall(ad in asignaturas_disponibles, dd in dias_disponibles)((
             %En una columna (unico dia) puede aparecer una asignatura 0 veces o...
             count(hd in horas_disponibles)(matriz_asig[hd, dd] = ad) == 0 \/  
             %... tantas como horas tenga su bloque
             count(hd in horas_disponibles)(matriz_asig[hd, dd] = ad) == bloques_de[ad] 
));

solve satisfy;

%SALIDA POR PANTALLA
output [if dd == 1 then "              \(margen_superior[dd])" 
        else "\(margen_superior[dd]) " 
        endif 
        ++ if dd ==  5 then "\n" 
        else "" 
        endif 
        | dd in dias_disponibles];
        
output[if dd == 1 then "\(margen_izquierdo[hd]) -> " 
       else "" endif
       ++
       if     fix(matriz_asig[hd,dd]) == 8     then "\(nombres_totales[15])" 
       elseif fix(matriz_asig[hd,dd]) == 9     then "\(nombres_totales[16])" 
       elseif fix(matriz_asig[hd,dd]) == 10    then "\(nombres_totales[17])" 
       elseif fix(matriz_bloq[hd,dd]) == 2     then "\(nombres_totales[fix(matriz_asig[hd,dd])*2])" 
       else "\(nombres_totales[fix(matriz_asig[hd,dd])*2-1])" 
       endif  
       ++ 
       if dd == 5 then "\n" 
       else "" endif 
       | hd in horas_disponibles,  dd in dias_disponibles];