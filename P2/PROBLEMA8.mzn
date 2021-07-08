include "globals.mzn";
%Ejercicio 8

%DECLARACION DE VARIABLES
int: trabajadores_totales = 3;                    %Cantidad de trabajadores que tenemos
int: tiempos_totales      = sum(duracion_tareas); %Es la cantidad maxima de tiempo que puede tardar, equivaldria a cada tarea secuencialmente
var 1..tiempos_totales: menor_tiempo;             %Variable que queremos minimizar 

%DECLARACION DE CONJUNTO DE VALORES
set of int: nombres_disponibles         = 1..10;  %Cantidad de nombres. Son 9 tareas "A"-"I" y el "0"
set of int: tareas_disponibles          = 1..9;   %Cantidad de tareas a repartir
set of int: tareas_previas_disponibles  = 1..12;  %Cantidad de restricciones de precedencia que existen
set of int: trabajadores_disponibles    = 1..trabajadores_totales;   %Conjunto de valores para la matriz (1 por trabajador)

%DECLARACION DE VECTORES DE DATOS
array[tareas_disponibles] of var 1..tiempos_totales: comienza_en; %Vector que contiene el dia de inicio de cada tarea (tarea 1 =  posicion 1, etc)
array[tareas_disponibles] of var 1..tiempos_totales: termina_en; %Vector que contiene el dia de fin de cada tarea (tarea 1 =  posicion 1, etc)
array[tareas_disponibles] of int:   indice_tareas            = [1,2,3,4,5,6,7,8,9]; %Vector con el indice de cada tarea (A:1, B:2,..., I:9)
array[tareas_disponibles] of int:   duracion_tareas          = [7,3,1,8,2,1,1,3,2]; %Vector con la duracion de cada tarea (A:7, B:3,..., I:2)
array[tareas_disponibles] of int:   trabajadores_por_tarea   = [2,3,2,2,1,2,1,1,2]; %Vector con la cantidad de trabajadores necesarios por tarea
%Matriz con las restricciones de tener que terminar alguna tarea antes de empezar otra. En cada fila hay dos valores: | precedente, nueva |
array[tareas_previas_disponibles, 1..2] of int:      tareas_previas = [| 1,2 | 1,4 | 1,8 |  %A precedente de B, D, H
                                                                         2,3 |              %B precedente de C
                                                                         3,5 | 3,6 | 3,7 |  %C precedente de E, F, G
                                                                         4,5 | 4,6 | 4,7 |  %D precedente de E, F, G
                                                                         6,9 |              %F precedente de I
                                                                         8,9 |];            %H precedente de I

%DECLARACION DE VECTORES DE TEXTO PARA LA SALIDA
array[nombres_disponibles] of string: nombres_totales = ["0","A","B","C","D","E","F","G","H","I"]; %Nombre de cada tarea (incluido el "0")
array[trabajadores_disponibles,1..tiempos_totales] of var 0..9: asignaciones_finales;              %Matriz para la representacion de las tareas


%RESTRICCIONES
constraint
%Restriccion que se encarga de que la suma de trabajadores necesarios en cada dia no sea superior a 3
cumulative(comienza_en, duracion_tareas, trabajadores_por_tarea, trabajadores_totales) /\
maximum(menor_tiempo, termina_en) /\ %Nos quedamos con el maximo entre el ultimo dia en el que se termina una tarea o el menor tiempo necesario
forall(i in tareas_disponibles) (termina_en[i] = comienza_en[i] + duracion_tareas[i] ) /\ %Rellenamos el vector de cuando termina cada tarea
forall(p in tareas_previas_disponibles) (
       %Para cada tarea, su antecedente debe haber terminado antes de que empiece la tarea en cuestion
      comienza_en[tareas_previas[p,1]] + duracion_tareas[tareas_previas[p,1]] <= comienza_en[tareas_previas[p,2]]
); 

%Matriz de salida
constraint forall(i in 1..9) (               %para cada tarea
      %Si esta tarea necesita dos trabajadores
      if trabajadores_por_tarea[i] == 2 then 
            forall(j in comienza_en[i]..(termina_en[i]-1))(    %Desde que comienza esa tarea hasta que termina, rellenamos con su indice dos filas
                    asignaciones_finales[1,j] = i /\ asignaciones_finales[2,j] = i )
      %Si esta tarea necesita un trabajador
      elseif trabajadores_por_tarea[i] == 1 then 
            forall(j in comienza_en[i]..(termina_en[i]-1))(%Desde que comienza la tarea hasta su fin, rellenamos con su indice una fila cualquiera
                    asignaciones_finales[1,j] = i  \/ asignaciones_finales[2,j] = i \/ asignaciones_finales[3,j] = i)
      %Si esta tarea necesita tres trabajadores
      elseif trabajadores_por_tarea[i] == 3 then 
            forall(j in comienza_en[i]..(termina_en[i]-1))( %Desde que comienza esa tarea hasta que termina, rellenamos con su indice tres filas
                    asignaciones_finales[1,j] = i  /\ asignaciones_finales[2,j] = i /\ asignaciones_finales[3,j] = i)                                                        
      else (true)
      endif
);

solve minimize menor_tiempo; %Minimizamos el tiempo que tarde en realizar todas las tareas cumpliendo las restricciones

%SALIDA POR PANTALLA
output["TIEMPO MINIMO: \(menor_tiempo)\n"];
output["*****\n"];
output["Tarea \(nombres_totales[indice_tareas[i]+1]) empieza en tiempo \(comienza_en[i])\n" | i in 1..9];
output["*****\n"];
output["\(nombres_totales[fix(asignaciones_finales[j,i]) +1]) " ++ if i==22 then "\n" else "" endif | j in 1..3,  i in 1..22];

