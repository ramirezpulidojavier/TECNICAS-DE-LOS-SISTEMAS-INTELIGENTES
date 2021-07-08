package src_Ramirez_Pulido_Javier;

import core.game.Observation;
import core.game.StateObservation;
import ontology.Types;
import src_Ramirez_Pulido_Javier.Esquivar.orientacion;
import tools.Vector2d;

import java.awt.Event;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.PriorityQueue;

import com.sun.net.httpserver.Authenticator;
import javax.sound.midi.SysexMessage;

/**
 * Created by Javier Ramirez Pulido on 12/04/21.
 */
public class PathFinder
{
	//Observador que tiene informacion sobre el sistema en cada momento (avatar, posicion, etc) 
	public StateObservation state;
	//Matriz que contiene el mapa que estemos utilizando. Contiene los objetos distribuidos en el (enemigos, gemas, muros, portales...)
    public ArrayList<core.game.Observation> grid[][];
    //Vector que contiene la coordenada x de cada vecino del nodo actual ordenado con la secuencia en la que queremos recorrer estos
    private static final int[] x_neighs = new int[]{0, 0, -1, 1};
    //Vector que contiene la coordenada y de cada vecino del nodo actual ordenado con la secuencia en la que queremos recorrer estos
    private static final int[] y_neighs = new int[]{-1, 1, 0, 0};

    //Constructor por defecto
    public PathFinder(){}

    //Funcion que inicializa el state del sistema y la matriz del mapa 
    //obs: observador del sistema con la informacion para el estado y el mapa
    public void run(StateObservation obs){
    	
    	this.state = obs;
    	this.grid = this.state.getObservationGrid();
    
    }

    //Funcion manhattan para obtener la distancia entre dos nodos
    //node: Nodo de origen desde el que calcular la distancia
    //goal: Nodo de destino hacia el que calcular la distancia
	private int heuristica(Node node, Node goal){
		
		return (int) (Math.abs(node.coordenada_x - goal.coordenada_x) + Math.abs(node.coordenada_y - goal.coordenada_y));
	
	}

	//Funcion que calcula el camino cuando llegamos al nodo objetivo recorriendo de padre en padre (el padre del primer nodo es null)
	//node: Nodo objetivo que añadir al camino
	private ArrayList<Node> calcular_camino(Node node){
		
		//Creamos un vector de nodos para el camino
		ArrayList<Node> camino = new ArrayList<Node>();

		//Mientras el nodo no es nulo (mientras no lleguemos al padre del primero) 
		while(node != null)
		{
			//Si el nodo del padre no es nulo (no añadimos al camino el nodo en el que estemos actualmente)
			if(node.nodo_padre != null)
				//Se añade al camino el nodo actual
				camino.add(0,node);
			//Pasamos al padre del nodo actual y repetimos el procedimiento. Se ha ido guardando el padre para el camino mas corto
			node = node.nodo_padre;
		}
		
		//Devuelve el camino cuando lo conforma completo
		return camino;
	}

	//Funcion para obtener los vecinos de un nodo (los 4 de alrededor)
	//actual_nodo: nodo actual que necesitamos para conocer la posicion de los vecinos de alrededor
	private ArrayList<Node> obtener_vecinos(Node actual_node){
		
		//Creamos un vector de nodos que contendra los nodos vecinos
		ArrayList<Node> neighbours = new ArrayList<Node>();
		//Almacenamos las coordenadas de nuestro nodo actual para usarla en los calculos
		int x = (int) actual_node.coordenada_x;
		int y = (int) actual_node.coordenada_y;
		
		//Bucle que realiza 4 iteraciones , una por nodo vecino. Tambien valdria i<y_neighs 
		for(int i=0; i < x_neighs.length; i++){
				
			//Si esa posicion en la que esta el vecino esta vacia (no hay objetos como muros, enemigos, gemas, etc)
			if(grid[x+x_neighs[i]][y+y_neighs[i]].isEmpty())
				//Añadimos ese nodo como un vecino del nodo actual
				neighbours.add(new Node(new Vector2d(x+x_neighs[i],y+y_neighs[i])));
			
			//Si no esta vacia la posicion del vecino
			else{
				
				//Comprueba que el objeto que esta en ese nodo no es un muro (estos se identifican con el id = 0)	
				if(grid[x+x_neighs[i]][y+y_neighs[i]].get(0).itype != 0)
					//Añadimos ese nodo como un vecino del nodo actual
					neighbours.add(new Node(new Vector2d(x+x_neighs[i],y+y_neighs[i])));
			
			}
			
		}

		//Devuelve el vector de vecino
		return neighbours;
		
	}
	
	//Algoritmo de A*
	//start: nodo de comienzo del camino
	//goal: nodo destino del camino
	//obs: observador del sistema para conocer la orientacion del avatar, cuestion a tener en cuenta en el coste del camino
	public ArrayList<Node> a_star(Node start, Node goal, StateObservation obs)
	{
		//Nodo actual
		Node current = null;
		//Lista de abiertos en la que estan los nodos a evaluar. En este se van metiendo los hijos de los nodos evaluados
		PriorityQueue<Node> openList = new PriorityQueue<Node>();
		//Lista de cerrados cuando han sido evaluados en abiertos
		PriorityQueue<Node> closedList = new PriorityQueue<Node>();
		//Vector de nodos que contendra el camino de nodos mas corto desde 'start' hasta 'goal'
		ArrayList<Node> camino = new ArrayList<Node>();
		//Enum que contiene la orientacion del avatar en cada momento
		orientacion orientacione = orientacion.Norte;
		
		//Incialmente el coste del nodo del que partimos es 0 porque partimos de el
		start.coste = 0;
		//La heuristica es la distancia en casillas entre un nodo y el objetivo para avanzar hacia aquellos que mas se acerquen (heuristica menor)
		start.heuristica = heuristica(start, goal);
		
		//Metemos en abierto el nodo del que partimos para evaluarlo y desarrollar sus hijos
		openList.add(start);

		//Bucle mientras existan nodos en la lista de abiertos (nodos a evaluar)
		while(openList.size() != 0){
		
			//Nos pasamos al nodo de los que estan en abierto que tiene menor coste. Poll obtiene el valor con mas prioridad de
			//una priority queue y en este ordenamos por coste de menor a mayor
			current = openList.poll();
			//Como lo evaluamos, este pasa a cerrados como desarrollado
			closedList.add(current);
			
			//Si estamos en una casilla diferente a aquella de la que partimos
			if (current != start) {
				//Si la actual esta a la derecha de la que procedemos, vamos hacia el este
				if(current.coordenada_x - current.nodo_padre.coordenada_x == 1) orientacione = orientacion.Este;
				//Si la actual esta a la izquierda de la que procedemos, vamos hacia el oeste
				else if(current.coordenada_x - current.nodo_padre.coordenada_x == -1) orientacione = orientacion.Oeste;
				//Si la actual esta debajo de la que procedemos, vamos hacia el sur
				else if(current.coordenada_y - current.nodo_padre.coordenada_y == 1) orientacione = orientacion.Sur;
				//Si la actual esta encima de la que procedemos, vamos hacia el norte
				else if(current.coordenada_y - current.nodo_padre.coordenada_y == -1) orientacione = orientacion.Norte;
			
			//Si estamos en el nodo de inicio obtenemos la orientacion por defecto que determine el sistema (primera de todas)
			}else	orientacione = getOrientation(obs);
			
			//Si he llegado al nodo destino
			if(current.equals(goal))				
				//Calculo el camino recorriendo los padres almacenados y lo devuelvo como camino final seleccionado
				return calcular_camino(current);
				
			
			//Si llegamos aqui es porque aun no llegamos al nodo destino asi que evaluamos los vecinos
			ArrayList<Node> neighbours = obtener_vecinos(current);

			//Recorremos todos los nodos vecinos al nodo actual. Son aquellos de alrededor que no son muros
			for(int i=0; i < neighbours.size(); i++){
				
				//Sacamos el vecino a evaluar por orden
				Node actual_neighbour = neighbours.get(i);

				//La distancia actual hasta el es 0 porque no sabemos cuanto cuesta llegar
				int current_distance = 0; 
				
				//Si este vecino esta delante (en la orientacion) del avatar, el coste es el que tenga el vecino (sera 1)
				if( esta_delante(current, neighbours.get(i), orientacione) )
					current_distance = actual_neighbour.coste;
				
				//Si no esta delante, tendremos que gastar un tick en girar y otro en ir, por eso cuesta uno mas de lo que costaria normal
				else 
					current_distance = actual_neighbour.coste + 1;

				//Si el vecino actual no esta ni en abierto ni en cerrados aun
				if(!openList.contains(actual_neighbour) && !closedList.contains(actual_neighbour)){
						
					//El coste para llegar a el es el paso o giro+paso que tenamos que dar y el coste de haber llegado al actual
					actual_neighbour.coste = current_distance + current.coste;
					//Calculamos su distancia al nodo objetivo para conocer la heuristica y escoger los nodos que se acercan
					actual_neighbour.heuristica += heuristica(actual_neighbour, goal);
					//Guardamos el nodo padre para luego conformar el camino ascendiendo entre nodos
					actual_neighbour.nodo_padre = current;
					//Lo metemos en abiertos para desarrollarlo y evaluar sus hijos 
					openList.add(actual_neighbour);
				
				//Si esta en abiertos o cerrados tenemos que ver si el coste hasta este es mejor que el que tenemos y reemplazamos 
				}else{
					
					//Nodo auxiliar donde iremos almacenando nodos de cada lista buscando encontrar el que queremos comparar
					Node aux = null;
					//Vector auxiliar de nodos para ir metiendo aquellos que no son los deseados y no buscar entre ellos en adelante
					PriorityQueue<Node>auxiliar = new PriorityQueue<Node>();
					//Booleano para dejar de buscar cuando encontremos el que buscamos, asi quitamos iteraciones vacias
					boolean seguir=true;
					
					//Si donde estaba es en abiertos, buscamos en el
					if(openList.contains(actual_neighbour)) {					
						
						//Mientras no vaciemos todo abiertos o no lo encontremos
						while(!openList.isEmpty() && seguir) {
							
							//Sacamos un elemento de abiertos
							aux = openList.poll();
							
							//Si este elemento sacado es el que buscamos
							if (aux.equals(actual_neighbour)) {
								
								//Digo que lo he encontrado para que deje de iterar
								seguir = false;
								
								//Si el coste para llegar a este nodo actualmente es menor que el tenia por otro camino
								if(current_distance + current.coste < aux.coste) {
									
									//Actualizo el coste hasta este nodo para que sea el menor
									actual_neighbour.coste = current_distance+current.coste;
									//Cambiamos el padre para que llegue a este por otro camino diferente al anterior
									actual_neighbour.nodo_padre = current;
									//Añadimos en auxiliar este nodo para volcarlo en abiertos al terminar
									auxiliar.add(actual_neighbour);
								
								//Si he encontrado el nodo que queria pero su coste era menor o igual, nos quedamos con aquel
								}else auxiliar.add(aux);
							
							//Si el elemento sacado de abiertos no es el que buscamos, al auxiliar y luego los unimos de nuevo
							}else auxiliar.add(aux);
							
						}
						
						//Reintroducimos aquellos nodos sacados de abiertos buscando el que queriamos en abiertos
						while(!auxiliar.isEmpty()) {
							openList.add(auxiliar.poll());
						}

					//Si donde estaba es en cerrados, buscamos en el 
					}else {
					
						//Reinicializamos la condicion de parada por si almacena un valor basura de otras iteraciones
						seguir = true;
						
						//Mientras no hayamos recorrido todo cerrados o no lo hayamos encontrado
						while(!closedList.isEmpty() && seguir) {
							
							//Sacamos un elemento de cerrados
							aux = closedList.poll();
							
							//Si este elemento sacado es el que buscamos
							if (aux.equals(actual_neighbour)) {
								
								//Digo que lo he encontrado para que deje de iterar
								seguir = false;
								
								//Si el coste para llegar a este nodo actualmente es menor que el tenia por otro camino
								if(current_distance + current.coste < aux.coste) {
												
									//Actualizo el coste hasta este nodo para que sea el menor
									actual_neighbour.coste = current_distance+current.coste;
									//Cambiamos el padre para que llegue a este por otro camino diferente al anterior
									actual_neighbour.nodo_padre = current;
									//Añadimos en abiertos este nodo para volver a desarrollarlo
									openList.add(actual_neighbour);
								
								//Si he encontrado el nodo que queria pero su coste era menor o igual, nos quedamos con aquel
								}else auxiliar.add(aux);
							
							//Si el elemento sacado de cerrados no es el que buscamos, al auxiliar y luego los unimos de nuevo
							}else auxiliar.add(aux);
							
						}
						
						//Reintroducimos aquellos nodos sacados de cerrados buscando el que queriamos 
						while(!auxiliar.isEmpty()) {
							closedList.add(auxiliar.poll());
						}
						
						
					}
					
				} 
				
			}
			
		}

		//Devolvemos el camino conformado
        return camino;
	}
	
	//Funcion que transforma la orientacion que tiene el avatar en un enum mas intuitivo. En el sistema se representa con 
	//coordenadas, por ejemplo las coordenadas (1,0) significan derecha. Utilizamos un enum para manejar con comodidad
	//la orientacion
	//stateObs: observador con la informacion de la orientacion EN COORDENADAS del avatar
	public orientacion getOrientation(StateObservation stateObs){
		
		//Comprobamos la coordenada x. Como no hay movimientos diagonales, si esta es distinta a 0, la orientacion es horizontal
		switch((int)stateObs.getAvatarOrientation().x){
			
			//Si es -1, es horizontal hacia la izquierda
			case -1:
				return orientacion.Oeste;
			
			//Si es 1, es horizontal hacia la izquierda
			case 1:
				return orientacion.Este;
				
		}
		
		//Comprobamos la coordenada y. Como no hay movimientos diagonales, si esta es distinta a 0, la orientacion es vertical
		switch((int)stateObs.getAvatarOrientation().y){
		
			//Si es -1, es vertical hacia arriba
			case -1:
				return orientacion.Norte;
		
			//Si es 1, es vertical hacia abajo
			case 1:
				return orientacion.Sur;
				
		}
	
		//Por defecto devuelve Norte, pero no deberia darse el caso de llegar hasta aqui
		return orientacion.Norte;
		
	}

	//Funcion que confirma si un nodo esta delante del otro (Importante saber esto para contar con el tick del giro o no)
	//current: nodo en el que nos encontramos actualmente
	//vecino: nodo que comprobamos si tenemos delante o en otra direccion/sentido
	//orientacion: orientacion hacia la que esta orientado el avatar
	public boolean esta_delante(Node current, Node vecino, orientacion orientacion)
	{
		//Si la orientacion es hacia la derecha y el nodo esta a la derecha, devuelve que si esta delante
		if(((float)vecino.coordenada_x - (float)current.coordenada_x == 1) && orientacion == orientacion.Este) return true; 
		//Si la orientacion es hacia la izquierda y el nodo esta a la izquierda, devuelve que si esta delante
		if(((float)vecino.coordenada_x - (float)current.coordenada_x == -1) && orientacion == orientacion.Oeste) return true; 
		//Si la orientacion es hacia abajo y el nodo esta debajo, devuelve que si esta delante
		if(((float)vecino.coordenada_y - (float)current.coordenada_y == 1) && orientacion == orientacion.Sur) return true; 
		//Si la orientacion es hacia arriba y el nodo esta arriba, devuelve que si esta delante
		if(((float)vecino.coordenada_y - (float)current.coordenada_y == -1) && orientacion == orientacion.Norte) return true; 
		
		//Si no se ha cumplido ninguna de las condiciones anteriores es porque el nodo no esta delante
		return false;
		
	}

	
}
