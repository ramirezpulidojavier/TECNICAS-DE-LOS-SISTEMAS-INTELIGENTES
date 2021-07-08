include "globals.mzn";
%Ejercicio 5 

%Vamos a declarar las variables para este problema

%Variable con el intervalo posible de los valores de las horas (9-10, 10-11, 12-13)
set of int: horas_disp = 9..12;

%Variable con el intervalo posible de los valores de aulas y las asignaturas (1, 2, 3)
set of int: cant_aulas = 1..3;
set of int: cant_asignat = 1..3;

%Vector con los nombres de los cuatro grupos y las tres asignaturas que tenemos 
set of int: cant_grupos = 1..4; % Tenemos 4 grupos (G1, G2, G3, G4)
array[cant_grupos] of string: grupos = ["G1","G2","G3","G4"]; % Array con los nombres de los grupos
array[cant_asignat] of string: asignaturas = ["IA","TSI","FBD"];

%Variable con el intervalo posible de los valores de las horas (son 5 horas, las 9, las 10, las 11, las 12 y las 13)
set of int: horas_salida = 1..5; 
%Vector con el numero de las horas 
array[horas_salida] of string: horas_disps_salida = [" 9","10","11","12", "13"];
%Nombres de las asignatuas con su correspondiente grupo y profesor para mostrarlas para verlo en la salida correctamente 
array[1..12] of string: asig_grup_prof = ["IA-G1 (P1)", "IA-G2 (P2) ", "IA-G3 (P3)", "IA-G4 (P4)", "TSI-G1 (P3)", "TSI-G2 (P3)", "TSI-G3 (P4)", "TSI-G4 (P3)", "FBD-G1 (P1)", "FBD-G2 (P1)", "FBD-G3 (P1)", "FBD-G4 (P2)"];

%Representamos las horas de clase como una matriz de asignaturas x grupos (e.g [3,4]=9 nos quiere decir que FBD (asig 3) grupo 4 se da a las 9:00                                           
array[cant_asignat, cant_grupos] of var horas_disp: horas_disps;
%Representamos las aulas como una matriz de asignaturas x grupos (matriz 3x4) (e.g [3,4]=1 nos quiere decir que FBD (asig 3) grupo 4 se da en la clase 1
array[cant_asignat, cant_grupos] of var cant_aulas: aulas; 

%Siguiendo el ejercicio, tenemos que satisfacer una serie de restricciones que se nos dan para este ejercicio y que son las siguientes
%Cada grupo tiene una sola asignatura en cada momento:
constraint forall(grupo in cant_grupos)(alldifferent([horas_disps[asig, grupo] | asig in cant_asignat]));
%En cada aula un solo profesor:
     %%%%Comprobamos que las horas disponibles de dos profesores en el mismo aula no sean las mismas y el aula de ellos no sea la misma
     %%%%Haciendo uso de for encadenados para recorrer ambas matrices (para ello necesitamos 4 variables, 2 para cada matriz)
constraint forall(i in cant_asignat, j in cant_grupos) (forall(k in cant_asignat, l in cant_grupos) ((i == k /\ j == l) \/ horas_disps[i, j] != horas_disps[k, l] \/ aulas[i, j] != aulas[k, l])); 

% Profesor 4 aula 3: 
constraint aulas[1,4] == 3 /\ aulas[2,3] == 3; %Es el que le da la asignauta de IA al grupo 4 y la asignatura de TSI al grupo 3

% Profesor 2 aula 2:
constraint aulas[1,2] == 2 /\ aulas[3,4] == 2; %Es el que le da la asignatura de IA al grupo 2 y la asignatura de FBD al grupo 4

%TSI aula 2 o 3:
constraint forall(grupo in 1..4)( aulas[2,grupo] == 2 \/ aulas[2,grupo] == 3);

%Profesor da clase a un único grupo y/o asignatura en cada momento:
    %%Un profesor imparte IA al grupo 3 o TSI al grupo 1 o TSI al grupo 2 o TSI al grupo 4
constraint alldifferent([horas_disps[1,3], horas_disps[2,1], horas_disps[2,2], horas_disps[2,4]]);
    %%Otro imparte FBD al grupo 1 o FBD al grupo 2 o FBD al grupo 3 o IA al grupo 1
constraint alldifferent([horas_disps[3,1], horas_disps[3,2], horas_disps[3,3], horas_disps[1,1]]); 
    %%Otro imparte IA al grupo 4 o TSI al grupo 3
constraint alldifferent([horas_disps[1,4], horas_disps[2,3]]); 
    %%Otro imparte IA al grupo 2 o FBD al grupo 4
constraint alldifferent([horas_disps[1,2], horas_disps[3,4]]);


%IA G1 9-10 y G3 clase 11-12 y aula 1:¡
constraint horas_disps[1,1] == 9 /\
           horas_disps[1,3] == 11 /\ aulas[1,3] == 1;

%Profesor grupos y horas concretas de clase (ni FBD para el G4 ni IA para el grupo 2 se pueden impartir entre las 11 y las 13: 
constraint horas_disps[3,4] != 11 /\ horas_disps[3,4] != 12; %FBD G4 
constraint horas_disps[1,2] != 11 /\ horas_disps[1,2] != 12; %IA G2 

%Satisfacemos las restricciones y por tanto resolvemos el problema
solve satisfy;

%Mostramos por pantalla para las 3 aulas y para cada franja horaria (9-10, 10-11, 11-12, 12-13) las asignatuas que se imparten a esa hora en esa aula junto con el grupo que le corresponde y el profesor que las imparte
output ["                  Aula1                Aula2            Aula3 \n"];
output [if j == 1 /\ asigna == 1 /\ grupo == 1 then
            "\(horas_disps_salida[i-8]): - \(horas_disps_salida[i-7]) -> "
       else "" endif  ++
       if fix(horas_disps[asigna, grupo]) == i /\ fix(aulas[asigna, grupo]) == j then
            "\(asig_grup_prof[(asigna-1)*4+grupo]) \t"
       else "" endif ++
       if  j == 3 /\ asigna == 3 /\ grupo == 4 then "\n"
       else "" endif
       | i in 9..12, j in 1..3, asigna in cant_asignat, grupo in cant_grupos];