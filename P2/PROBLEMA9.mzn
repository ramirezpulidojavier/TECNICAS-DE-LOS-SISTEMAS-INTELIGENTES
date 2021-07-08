include "globals.mzn";
%Ejercicio 9

%DECLARACION DE VARIABLES
var int:      paciente_mas_cercano ;  %Variable que contendra el indice del paciente mas cercano al que queremos evaluar

%DECLARACION DE CONJUNTO DE VALORES
set of int: pacientes_disponibles = 1..20;  %La cantidad de pacientes evaluados de los que tenemos datos previos
set of int: columnas_disponibles  = 1..4;   %Cantidad de sintomas que puede presentar cada paciente (cada diagnostico)

%DECLARACION DE VECTORES DE DATOS
%Matriz que contiene por cada fila i los sintomas del paciente i
array[pacientes_disponibles,columnas_disponibles] of int: diagnosticos_anteriores = [| 0,0,1,1 | 1,1,1,0 | 1,1,0,1 | 1,0,0,1 | 1,1,0,1 | 
                                                                                       0,1,1,1 | 1,0,0,0 | 1,1,0,0 | 0,1,0,0 | 0,0,1,1 | 
                                                                                       1,0,0,1 | 1,0,0,1 | 0,1,1,0 | 1,1,0,0 | 1,0,1,0 | 
                                                                                       1,0,0,0 | 1,0,0,1 | 0,1,1,0 | 0,0,1,0 | 1,0,1,0 |];
                                   
array[columnas_disponibles] of var int: nuevo_paciente = [0,1,1,1];  %Sintomas del nuevo paciente que vamos a evaluar 
array[pacientes_disponibles] of var int : cada_distancia ;           %vector con la distancia del nuevo paciente a cada uno de los 20 restantes
%  1 -> COVID // 2 -> Gripe // 3 -> Alergias
%Por cada posicion tenemos que enfermedad se diagnostico a cada paciente almacenado (Ej: 1º covid, ..., 13º gripe,...19º alergias...)
array[pacientes_disponibles] of var int: enfermedades_diagnosticadas = [1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3];



%FUNCIONES PROPORCIONADAS EN EL ENUNCIADO

% Calcular la distancia entre dos pacientes.
%
predicate distancia(array[int,int] of int: a, array[int] of var int: v, var int:d , var int: j) =
  d = sum(i in columnas_disponibles) ((a[j,i]-v[i])*(a[j,i]-v[i])) /\ d >= 0 ;
 
% Recuperar el índice del menor valor de un array (i.e. argmin)
%
predicate paciente_mas_cercano_minimo(var int: mi, array[int] of var int: x) = exists(i in index_set(x)) (x[i] = min(x) /\ mi = i);


%RESTRICCIONES
%Almacenamos en cada posicion i del vector de distancias la distancia entre el paciente actual y el paciente i
constraint forall(i in pacientes_disponibles)(distancia(diagnosticos_anteriores,nuevo_paciente,cada_distancia[i],i));
%Almacenamos en el indice del paciente mas cercano el indice del paciente con el que el paciente actual tenga menos distancia
constraint paciente_mas_cercano_minimo(paciente_mas_cercano,cada_distancia);

solve satisfy;


%SALIDA POR PANTALLA
output["Distancias con cada paciente: \n" ] 
      ++ 
      ["Con el paciente \(i): \(cada_distancia[i]) \n" | i in pacientes_disponibles]  %Mostramos todas las distancias
      ++ 
      ["\nPaciente mas cercano -> \(paciente_mas_cercano) \n"]                        %Quien es el paciente antiguo mas cercano
      ++ 
      ["Probable diagnostico -> "]                                                    %El probable dignostico
      ++ 
      [if     fix(enfermedades_diagnosticadas[paciente_mas_cercano])==1 then "COVID" 
      elseif  fix(enfermedades_diagnosticadas[paciente_mas_cercano]) == 2 then "Gripe" 
      else "Alergias" endif ];