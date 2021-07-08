include "globals.mzn";
%Ejercicio 1 

%Vamos a declarar las variables para este problema

%Valores que puede tener cada letra (un numero del 0 al 9 incluidos ambos)
set of int: valores = 0..9;

%Vamos a tener un vector con las letras_valores que se van a codificar con un unico digito
%En la suma tenemos 8 letras_valores por lo que nuestro vector tendra 8 posiciones y querremos acceder a cada una de ellas para asociar los valores posibles
%Variable para dar tamaño a nuestro vector mencionado
set of int: pos_valores = 0..9; 

%Vector que va a contener la asignacion de digitos a letras (e.g. letra I valor 7 ó letra N valor 2)
array [pos_valores] of var valores: letras_valores;


%Como no conocemos los valores asociados a cada letra es conveniente llevar la cuenta del ac que pueden llevar en cada suma
%y para ello creamos las siguientes variables
var int : ac;
var int : ac_1;
var int : ac_2;
var int : ac_3;
var int : ac_4;

%Queremos que a cada letra se le asigne un valor diferente y para ello se puede utilizar la funcion alldifferent 
constraint alldifferent(letras_valores);

%Se nos pide satisfacer la siguiente suma
%      SIX
% +  SEVEN
% +  SEVEN
%-----------
%   TWENTY

%Para poner las siguiente restricciones voy a indicar el orden que le he dado a cada letra dentro del vector
%I = letras_valores[0]    %E = letras_valores[1]    %X = letras_valores[2]
%S = letras_valores[3]    %Y = letras_valores[4]    %W = letras_valores[5]
%N = letras_valores[7]    %V = letras_valores[6]    %resto = letras_valores[8]    


%Vamos a hacer la suma con la correspondencia que acabamos de mencionar (por columnas de derecha a izquierda, como si lo hicieramos en mano y a papel)

%Empezamos por la columna X+N+N=Y
constraint (letras_valores[2] + letras_valores[7] + letras_valores[7]) mod 10 == letras_valores[4];

%Y consideramos el posible acarreo que podamos tener de sumar valores cuyo resultado sea >=10
ac = (letras_valores[2] + letras_valores[7] + letras_valores[7]) div 10;

%Seguimos por la columa I+E+E=T teniendo en cuenta el acarreo que se ha podido producir en la suma anterior
constraint (letras_valores[0] + letras_valores[1] + letras_valores[1] + ac) mod 10 == letras_valores[8];

%Y de nuevo consideramos el posible acarreo que podamos tener de sumar valores cuyo resultado sea >=10
ac_1 = (letras_valores[0] + letras_valores[1] + letras_valores[1] + ac) div 10; 

%Vamos a hacer la suma S+V+V=N teniendo en cuenta el acarreo que se ha podido producir en la suma anterior
constraint (letras_valores[3] + letras_valores[6] + letras_valores[6] + ac_1) mod 10 == letras_valores[7]; 

%Y de nuevo consideramos el posible acarreo que podamos tener de sumar valores cuyo resultado sea >=10
ac_2 = (letras_valores[3] + letras_valores[6] + letras_valores[6] + ac_1) div 10; 

%Suma E+E=E teniendo en cuenta el acarreo que se ha podido producir en la suma anterior
constraint (letras_valores[1] + letras_valores[1] + ac_2) mod 10 == letras_valores[1]; 

%Y de nuevo consideramos el posible acarreo que podamos tener de sumar valores cuyo resultado sea >=10
ac_3 = (letras_valores[1] + letras_valores[1] + ac_2) div 10; 

%Suma S+S=W teniendo en cuenta el acarreo que se ha podido producir en la suma anterior
constraint (letras_valores[3] + letras_valores[3] + ac_3) mod 10 == letras_valores[5]; 

%Y de nuevo consideramos el posible acarreo que podamos tener de sumar valores cuyo resultado sea >=10
ac_4 = (letras_valores[3] + letras_valores[3] + ac_3) div 10; 

%Al final de la suma tenemos la letra T que es el resultado de todos los acarreos que se han dado a lo largo de la suma
constraint letras_valores[8] == ac_4;

%Satisfacemos las restricciones y por tanto resolvemos el problema
solve satisfy;

%Mostramos por pantalla los valores del vector correspondientes para nuestra suma SIX+SEVEN+SEVEN=TWENTY
output ["\t     \(letras_valores[3])\(letras_valores[0])\(letras_valores[2])\n \t + \(letras_valores[3])\(letras_valores[1])\(letras_valores[6])\(letras_valores[1])\(letras_valores[7])\n \t + \(letras_valores[3])\(letras_valores[1])\(letras_valores[6])\(letras_valores[1])\(letras_valores[7])\n \t ========\n \t  \(letras_valores[8])\(letras_valores[5])\(letras_valores[1])\(letras_valores[7])\(letras_valores[8])\(letras_valores[4])\n"]; 
