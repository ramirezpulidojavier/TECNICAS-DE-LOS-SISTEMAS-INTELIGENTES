include "globals.mzn";
%Ejercicio 3

%Vamos a declarar las variables para este problema

%Rangos para el numero de paises que tenemos que son 13, por tanto, de [1-13] y el numero de colores que tenemos que son 5, por tanto [1-5]
set of int: cant_paises = 1..13;
set of int: cant_col = 1..5; 

% Array con los nombres de los 13 paises diferentes
array [cant_paises] of string: nombres_paises=["ARGENTINA        ","BOLIVIA          ","PARAGUAY         ","GUYANA           ","BRASIL           ","CHILE            ","URUGUAY          ","PERU             ", "GUAYANA FRANCESA ","ECUADOR          ","COLOMBIA         ","VENEZUELA        ","SURINAM          "];
                                           
%Vector para almacenar los costes de cada color: verde 100, naranja 200, rojo 300, azul 400, amarillo 500
array [cant_col] of var int: costes;

%Vector con el nombre de los colores 
array [cant_col] of string: nom_col=["VERDE","NARANJA","ROJO","AZUL","AMARILLO"];

%Vector con los diferentes paises y los colores que se han empleado en cada uno de ellos
array [cant_paises] of var cant_col: paises;
%Vector para almacenar la cantidad de paises que se ha coloreado con cada uno de los 5 colores diferentes que tenemos
array [cant_col] of var int: colores;
 
%Tenemos que pintar los paises de tal forma que dos paises limitrofes seran coloreados con distinto color, asi que vamos a indicar para cada pais
%cuales son sus paises limitrofes

%Restricion de los paises limitrofes a Argentina
constraint paises[1] != paises[2] /\ paises[1] != paises[5] /\ paises[1] != paises[3] /\ paises[1] != paises[6] /\ paises[1] != paises[7];
%Restricion de los paises limitrofes a Bolivia
constraint paises[2] != paises[5] /\ paises[2] != paises[6] /\ paises[2] != paises[3] /\ paises[2] != paises[8] ;
%Restricion de los paises limitrofes a Paraguay
constraint paises[3] != paises[7];
%Restricion de los paises limitrofes a Guyana
constraint paises[4] != paises[13] /\ paises[4] != paises[12];
%Restricion de los paises limitrofes a Brasil
constraint paises[5] != paises[11] /\ paises[5] != paises[9] /\ paises[5] != paises[4] /\ 
           paises[5] != paises[3] /\ paises[5] != paises[8] /\ paises[5] != paises[13] /\
           paises[5] != paises[7] /\ paises[5] != paises[12];
%Restricion de los paises limitrofes a Chile
constraint paises[6] != paises[8] ;
%Restricion de los paises limitrofes a Guayana Francesa
constraint paises[9] != paises[13];
%Restricion de los paises limitrofes a Ecuador
constraint paises[10] != paises[8];
%Restricion de los paises limitrofes a Colombia
constraint paises[11] != paises[10] /\ paises[11] != paises[8] /\ paises[11] != paises[12];

%Para cada color le asociamos su coste
constraint forall(i in cant_col)(costes[i] = i*100);

%El vector de colores tiene para cada posicion (para cada color) la cantidad de paises que han sido coloreados con dicho color
constraint forall(i in cant_col)(colores[i] = sum([1 | j in cant_paises where paises[j] == i]));

%Satisfacemos las restricciones y por tanto resolvemos el problema coloreando el mapa con el menor coste posible 
solve minimize colores[1]*100 + colores[2]*200 + colores[3]*300 + colores[4]*400 + colores[5]*500; %suma del numero de paises que usan un color * su coste

%Mostramos por pantalla el coste minimo de colorear el mapa y los paises junto al color utilizado en ellos y el coste de haber utilizado ese color
output["total: \(colores[1]*100 + colores[2]*200 + colores[3]*300 + colores[4]*400 + colores[5]*500)\n\n"];  
output ["\(nombres_paises[i]): \(paises[i])\t \(costes[paises[i]]) \n" | i in cant_paises];


