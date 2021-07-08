package src_Ramirez_Pulido_Javier;

import ontology.Types;
import tools.Direction;
import tools.Vector2d;

import java.util.ArrayList;

/**
 * Created by Javier Ramirez Pulido on 12/04/21.
 */
public class Node implements Comparable<Node>{

	//Nodo del que procedemos cuando analizamos el nodo actual. Equivale al padre en arbol de nodos
    Node nodo_padre;
    //Equivalente a g. Coste acumulado de llegar al nodo actual
    public int coste;
    //Coste de ir de un nodo a otro. En este caso es la distancia (numero de posiciones) entre el nodo actual y el siguiente
    public int heuristica;
    //Posicion horizontal (numero de columna) del nodo actual
    public int coordenada_x;
    //Posicion vertical (numero de fila) del nodo actual
    public int coordenada_y;
    //Posicion. Vector2d que contiene en la x el mismo valor que 'coordenada_x' y en y tiene 'coordenada_y'. Util para funciones que necesiten Vector2d
    public Vector2d position;
    

    //Constructor por parametros.
    //pos: contiene la posicion (coordenadas x e y) del nodo actual
    public Node(Vector2d pos)
    {
    	//Por defecto cuesta 1 paso llegar a este nodo 
        coste = 1;
        //Dependera del nodo al que queramos ir costara 1 (avanzar) o 2 (girar + avanzar)
        heuristica = 0;
        //Guardamos las coordenadas que tiene el vector2d que pasamos como parametro
        coordenada_x = (int)pos.x;
        coordenada_y = (int)pos.y;
        //Aun no sabemos quien es el nodo padre al crearlo
        nodo_padre = null;
        //Inicializamos la posicion con la introducida como parametro
        position = pos;
    }

    //Funcion que compara qué nodo tiene coste menor para ordenarlo en la priority queue
    //n: nodo con el que comparar el actual
    @Override
    public int compareTo(Node n) {
    	//Si el nodo actual tiene menos coste que aquel con el que se compara
        if(this.heuristica + this.coste < n.heuristica + n.coste)
            return -1;
        //Si el nodo actual tiene mas coste que aquel con el que se compara
        if(this.heuristica + this.coste > n.heuristica + n.coste)
            return 1;
        //Si no es ninguna de las dos, tienen el mismo coste y es indiferente el orden entre ellos (se ordenan por coste)
        return 0;
    }

    //Funcion para comparar dos nodos. Equivale al operador '=='
    //o: objeto con el que se compara
    @Override
    public boolean equals(Object o){
    	
    	//Para que dos nodos sean el mismo basta con que tengan las mismas coordenadas, por lo que se llama al comparador de Vector2d (compara x e y)
    	return this.position.equals(((Node)o).position);
    	
    }
}