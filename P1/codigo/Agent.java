package src_Ramirez_Pulido_Javier;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.Direction;
import tools.ElapsedCpuTimer;
import tools.Vector2d;


/**
 * Created by Javier Ramirez Pulido on 12/04/21.
 */
public class Agent extends AbstractPlayer{
	

	Vector2d fescala;
	Vector2d portal;
	
	//Enum que contiene el nivel en el que estamos
	private enum nivel{
		REACTIVO_SIMPLE, DELIBERATIVO_SIMPLE, DELIBERATIVO_COMPUESTO, REACTIVO_COMPUESTO;
	}
	//Vector de acciones
	public ArrayList<Types.ACTIONS> actions;
	//Objeto del tipo PathFinde  
	PathFinder pathfinder;
	//Camino de nodos
	ArrayList<Node>camino;
	//Booleano que se pone a true cuando queremos cambiar de gema
	public boolean cambio;
	//Booleano que se pone a true cuando queremos cambiar la ruta
	public boolean cambiar_recorrido;
	//Booleano que indica si hemos llegado a la meta o no
	public boolean meta_alcanzada;
	//Si el juego ha terminado
	boolean terminado;
	//Si tengo que huir
	boolean huyo ;
	//Numero de gemas que hay en el mapa originalmente
	int gemas_originales;
	//Coordenadas de la gema a por la que estoy yendo actualmente
	Vector2d gem_current;
	//Cambiar de gema
	boolean otra_gema;
	//Si hemos alcanzado una gema
	boolean gema_alcanzada;
	//Contiene el indice del enemigo mas cercano
	int enemigo_cercano;
	//Objeto de tipo Esquivar
	Esquivar esquive;
	//Vector de acciones a realizar para el reactivo
	ArrayList<Types.ACTIONS> movimiento_huida;
	//Vector de posiciones de enemigos
	ArrayList<Vector2d> pos_enemigos;
	//Tamaño de bloque para hacer a escala
	int blockSize;
	//Accion que introduciremos en el vector de acciones
	Types.ACTIONS action;
	//Creamos un objeto de tipo nivel que almacenara el nivel en el que nos encontramos
	private nivel nivel_actual;
	
	
	/**
	 * initialize all variables for the agent
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 */
	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
		
		//Constructor por defecto de PathFinder
		pathfinder = new PathFinder();
		//Inicializamos el observador y el mapa
		pathfinder.run(stateObs);
		
		
		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length); 
        
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
	
        //Inicializamos todas las variables con sus respectivos constructores o valores por defecto
        camino = new ArrayList<Node>();
        cambio = true;
        cambiar_recorrido = true;
        meta_alcanzada = true;
        terminado = false;
        huyo = false;
        otra_gema = false;
        gema_alcanzada = false;
        gemas_originales = gemas_en_el_mapa(stateObs);
        movimiento_huida = new ArrayList<Types.ACTIONS>();
		this.blockSize = stateObs.getBlockSize();
		pos_enemigos = new ArrayList<Vector2d>();
		enemigo_cercano = 0;
        
        
	
	}
	

	/**
	 * return the best action to arrive faster to the closest portal
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @return best	ACTION to arrive faster to the closest portal
	 */
	@Override
	public ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {

		//Inicializamos esquive con el constructor y el observador
		esquive = new Esquivar(stateObs);
		//Obtenemos las coordenadas del avatar es escala
		Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
		//Obtenemos la posicion de los enemigos
		ArrayList<Observation>[] npcs = stateObs.getNPCPositions();
		
		//Funcion que establece el nivel en el que nos encontramos a partir de la cantidad de gemas y enemigos que hay en el mapa
		asigna_nivel(this.gemas_recogidas(stateObs), stateObs, stateObs.getNPCPositions(), avatar);

		//Si el nivel es reactivo compuesto
		if(nivel_actual == nivel.REACTIVO_COMPUESTO){
			
			//Creamos un vector que contendra aquellos enemigos que esten lo suficientemente cercanos como para huir de ellos
    		ArrayList<Vector2d> enemigos_cercanos = new ArrayList<Vector2d>();
    		//Cantidad de enemigos de los que vamos a huir
    		int num_enemigos_huyo = 0;
    		
    		//Limpiamos los enemigos que tengamos almacenados
    		pos_enemigos.clear();
    		//Para todos los enemigos encontrados
            for (int i = 0; i < npcs.length; i++)
                for (core.game.Observation obs : npcs[i])
                	//añadimos en pos_enemigos la posicion de todos ellos
                    pos_enemigos.add(new Vector2d((int)(obs.position.x/this.blockSize), (int)(obs.position.y/this.blockSize)));
                 
            //Recorremos las posiciones de los enemigos
            for(int i = 0; i < pos_enemigos.size() ; i++)   
            	//Si esta a una distancia de la que deberiamos huir
            	if(debo_huir(avatar, pos_enemigos.get(i))) {
            		//Aumentamos el numero de enemigos de los que huimos
            		num_enemigos_huyo++;
            		//Añadimos al vector de enemigos de los que huir el actual
            		enemigos_cercanos.add(pos_enemigos.get(i));
            	}
            	
            //Si hay enemigos de los que huir pero no tenemos plan de movernos        
    		if(movimiento_huida.size() == 0 && num_enemigos_huyo>0){
    			
    			//Actualizamos la posicion de los enemigos
      			esquive.updateEnemies(stateObs);
      			//Almacenamos en el vector de acciones aquellas para huir de los enemigos cercanos
      			movimiento_huida = esquive.huir(avatar, esquive.getOrientation(stateObs), enemigos_cercanos);
      			
      		}

    		//Si tengo accion para esquivar al enemigo
    		if(movimiento_huida.size() > 0)	{
    			//Sacamos la primera accion a realizar
    			action = movimiento_huida.get(0);
    			//La eliminamos
   				movimiento_huida.remove(0);

   			//Si no hay plan de esquivar, se queda quieto
   			}else   action = Types.ACTIONS.ACTION_NIL; 
    		
    		//Cuando esquiva al enemigo sigue a por las gemas
    		cambio = true;
		
    	//Si el nivel es reactivo simple
		}else if(nivel_actual == nivel.REACTIVO_SIMPLE){
			
			//En un principio aun no huyo
			huyo = false;
			//Limpiamos los enemigos que tengamos almacenados
    		pos_enemigos.clear();
    		//Para todos los enemigos encontrados
            for (int i = 0; i < npcs.length; i++)
                for (core.game.Observation obs : npcs[i])
                	//añadimos en pos_enemigos la posicion de todos ellos
                    pos_enemigos.add(new Vector2d((int)(obs.position.x/this.blockSize), (int)(obs.position.y/this.blockSize)));
			
            //Recorremos todos los enemigos hasta que encuentre alguno del que huir
			for(int i = 0; i < pos_enemigos.size() && !huyo; i++) {
            	//Compruebo si su distancia es para huir o no
            	huyo = debo_huir(avatar, pos_enemigos.get(i));
            	//Guardamos el indice del enemigo del que huimos
            	enemigo_cercano = i;
            	
            }
			
			//Si no tengo plan de  esquivar pero debo huir
	  		if(movimiento_huida.size() == 0 && huyo)	
	  			//Llamo a la funcion que nos diga la accion o acciones a realizar para esquivar
	  			movimiento_huida = esquive.huir(avatar, esquive.getOrientation(stateObs), pos_enemigos);
	
	  		//Si tengo accion para esquivar al enemigo
    		if(movimiento_huida.size() > 0)	{
    			//Sacamos la primera accion a realizar
    			action = movimiento_huida.get(0);
    			//La eliminamos
   				movimiento_huida.remove(0);

   			//Si no hay plan de esquivar, se queda quieto
   			}else   action = Types.ACTIONS.ACTION_NIL; 
    		
    		//Cuando esquiva al enemigo sigue a por las gemas
    		cambio = true;
		
    	//Si el nivel en el que estamos es deliberativo simple
		}else if(nivel_actual == nivel.DELIBERATIVO_SIMPLE){
			
			//Si el avatar ha llegado al portal y no ha  el juego
			if(avatar.equals(portal) && !terminado){
				//Guardo que el juego ha 
				terminado = true;
				//Y que he alcanzado la meta
				meta_alcanzada = true;
			
			//Si no ha llegado al portal marco que no se ha alcanzado el destino
			}else meta_alcanzada = false;

			//Si tenemos que cambiar el camino y no ha  el juego
			if(cambiar_recorrido == true && !terminado){
				
				//Si hay enemigos actualizamos los enemigos
				if(npcs!=null)	esquive.updateEnemies(stateObs);
				//Llamamos a A* desde el nodo del avatar al portal
				camino = pathfinder.a_star(new Node(avatar), new Node(portal), stateObs);
				//No tenemos que cambiar el camino
				cambiar_recorrido = false;
				
			}

			//Si hay camino y no se ha alcanzado la meta
			if(!camino.isEmpty() && !meta_alcanzada){
				
				//Si la posicion del avatar es la siguiente del camino
				if(avatar.equals(camino.get(0).position))
					//Borramos esa posicion del camino porque ya la hemos alcanzado
					camino.remove(0);
				//Si el camino no esta vacio despues de borrar un elemento
				if(!camino.isEmpty())
					//Se saca cual es la siguiente accion a realizar
					action = siguiente_accion(new Node(avatar), camino.get(0));
			
			//Si no hay camino o se ha alcanzado la meta, no nos movemos
			}else action = Types.ACTIONS.ACTION_NIL;
		
		//Si el nivel es deliberativo compuesto
		}else if(nivel_actual == nivel.DELIBERATIVO_COMPUESTO){
			
			//Si quedan gemas en el mapa
			if(this.gemas_restantes(stateObs) > 0){
				
				//Si tenemos camino que recorrer
				if(!camino.isEmpty())
					//Si el avatar esta en la posicion de la gema actual
					if(avatar.equals(gem_current)){
						//He llegado a la gema
						gema_alcanzada = true;
						//Tengo que cambiar de gema
						cambio = true;
					//Si aun el avatar no esta en la posicion de la gema, no la he alcanzado
					}else gema_alcanzada = false;

				//Obtengo la posicion de las gemas 
				ArrayList<Observation>[] gem_positions = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
				
				//Si tenemos que cambiar de gemas y aun quedan
				if(cambio == true && gem_positions!=null){
					
					//Actualizamos los enemigos del mapa
					esquive.updateEnemies(stateObs);
					//Sacamos un camino para ir a la gema mas cercana
					camino = ir_gema_cercana(gem_positions[0], avatar, stateObs);
					//No hemos alcanzado la gema aun
					gema_alcanzada=false;
					//Si el camino tiene algun nodo
					if(camino.size()>0)
						//Obtenemos las coordenadas de la gema a por la que vamos
						gem_current = new Vector2d(camino.get(camino.size()-1).coordenada_x, camino.get(camino.size()-1).coordenada_y);
					//Aun no cambiamos de gema porque acabamos de establecerla como destino
					cambio = false;
					
				}
				
			}

			//Si hay camino y no se ha alcanzado la meta
			if(!camino.isEmpty() && !gema_alcanzada){
				
				//Si la posicion del avatar es la siguiente del camino
				if(avatar.equals(camino.get(0).position))
					//Borramos esa posicion del camino porque ya la hemos alcanzado
					camino.remove(0);
				//Si el camino no esta vacio despues de borrar un elemento
				if(!camino.isEmpty())
					//Se saca cual es la siguiente accion a realizar
					action = siguiente_accion(new Node(avatar), camino.get(0));
			
			//Si no hay camino o se ha alcanzado la meta, no nos movemos
			}else action = Types.ACTIONS.ACTION_NIL;
						
		}
		
		//Devolvemos la accion a realizar
        return action;
			
	}
	
	
	//Funcion que te devuelve la siguiente accion a realizar segun el nodo del que parte y al que vas
    private Types.ACTIONS siguiente_accion(Node estoy, Node voy){
    	//Si el nodo al que voy esta a la derecha del que estoy, voy a la derecha
		if(estoy.coordenada_x-voy.coordenada_x == -1) return Types.ACTIONS.ACTION_RIGHT;
		//Si el nodo al que voy esta a la izquierda del que estoy, voy a la izquierda
		else if(estoy.coordenada_x-voy.coordenada_x == 1) return Types.ACTIONS.ACTION_LEFT;
		//Si el nodo al que voy esta a encima del que estoy, voy hacia arriba
		else if(estoy.coordenada_y-voy.coordenada_y == 1) return Types.ACTIONS.ACTION_UP;
		//Si el nodo al que voy esta debajo del que estoy, voy hacia abajo
		else if(estoy.coordenada_y-voy.coordenada_y == -1) return Types.ACTIONS.ACTION_DOWN;
		
		//Si no, que devuelva accion nula
		return Types.ACTIONS.ACTION_NIL;
		
	}
    
    //Funcion que devuelve la cantidad de gemas que ha recogido el avatar
    protected int gemas_recogidas(StateObservation stateObs){
    	
    	if(stateObs.getAvatarResources().get(6) == null) return 0;
    	else return stateObs.getAvatarResources().get(6);
	}

    //Funcion que dice la cantidad de gemas que quedan en el mapa segun las que habia y las que hemos cogido
	protected int gemas_restantes(StateObservation stateObs){
	 
		return gemas_originales - gemas_recogidas(stateObs);
	
	}
	
	//Funcion que devuelve un camino de nodos hasta la gema mas cercana
	protected ArrayList<Node> ir_gema_cercana(ArrayList<core.game.Observation> gem_positions, Vector2d avatar, StateObservation stateObs){
		
		//Se declaran una distancia a 0 para llevar la cuenta de la distancia de la posicion actual a la gema
		//La mas cercana es la primera en un principio hasta que no se encuentre otra aun mas cercana
		int mas_cercana, distancia;
		distancia = mas_cercana = 0;
		//La distancia menor se inicializa al valor maximo para que por muy alta que sea, la primera se coja si o si
		int menor_distancia = Integer.MAX_VALUE;
		
		
		int contador = 0;
		//Mientras no recorramos todas las gemas
		while(contador<gem_positions.size()) {
			//Obtenemos la distancia desde nuestra posicion a la de la gema actual
			distancia= manhattan(avatar, new Vector2d((int)(gem_positions.get(contador).position.x/fescala.x), (int)(gem_positions.get(contador).position.y/fescala.y)));
			
			//Si la distancia a esta es menor que la mas pequeña observada
			if(distancia < menor_distancia) {
				//Actualizamos el valor de la distancia mas baja
				menor_distancia=distancia;
				//Guardamos el indice de la gema mas cercana hasta ahora
				mas_cercana = contador;				
			}
			contador++;
		}
		
		//Se devuelve un camino de nodos desde la posicion actual hasta la mas cercana de ellas	
		return pathfinder.a_star(new Node(avatar), new Node(new Vector2d((int)(gem_positions.get(mas_cercana).position.x/fescala.x), (int)(gem_positions.get(mas_cercana).position.y/fescala.y))), stateObs);
	}
	
	//Funcion que devuelve la cantidad de gemas que hay en el mapa originalmente
	protected int gemas_en_el_mapa(StateObservation stateObs)
	{
		//Numero de gemas en el mapa
		int contador = 0;
		//Sacamos el contenido del mapa del observador
		ArrayList<core.game.Observation> grid[][] = stateObs.getObservationGrid();
		
		//Recorremos la matriz del mapa entera
		for(int i = 0 ; i < grid.length; i++) {
			for(int j = 0; j < grid[0].length; j++) {
				if(!grid[i][j].isEmpty()) {
					//Cada vez que encontramos un nodo de tipo gema aumentamos el contador
					if(grid[i][j].get(0).itype == 6) contador++;
				}
				
			}
		}
		
		//Devolvemos el contador que contiene el numero de gemas
		return contador;
		
	}
	
	//Funcion que comprueba la distancia entre el avatar y el enemigo y determina si es suficiente para huir 
	private boolean debo_huir(Vector2d avatar, Vector2d enemigo){
		
		if(manhattan(avatar, enemigo) < 7) return true;
		else return false;
	}
	
	//Funcion manhattan para obtener la distancia entre dos nodos
    //node: Nodo de origen desde el que calcular la distancia
    //goal: Nodo de destino hacia el que calcular la distancia
	private int manhattan(Vector2d avatar, Vector2d enemigo){
		
		return (int) (Math.abs(avatar.x - enemigo.x) + Math.abs(avatar.y - enemigo.y));
	}
	
	//Funcion que comprueba si un mapa es deliberativo o no, lo cual depende de haber cogido todas las gemas o que no hubiese ninguna
	private boolean es_deliberativo(int n_gems, StateObservation stateObs) {
		return (n_gems == 9 || gemas_en_el_mapa(stateObs) == 0);
	}

	//Funcion que evalua el mapa y la situacion y decide en que nivel estamos de todos
	//n_gems: Numero de gemas recogidas por el avatar
	//stateObs: Observacion del estado actual
	//npcs: vector con las observaciones de los enemigos
	//avatar: posicion del avatar
	private void asigna_nivel(int n_gems, StateObservation stateObs, ArrayList<Observation>[] npcs, Vector2d avatar) {
		
		//Comprueba si es deliberativo
		if(es_deliberativo(n_gems, stateObs)){

			//Establece por defecto que sea deliberativo simple
			nivel_actual = nivel.DELIBERATIVO_SIMPLE;
			
			//Si hay enemigos
			if(npcs !=null) {
				
				//Si originalmente habia gemas en el mapa
				if(gemas_originales >0){
					
					//Limpiamos los enemigos que tengamos almacenados
					pos_enemigos.clear();
					//Recorremos todos los enemigos del mapa
					for (int i = 0; i < npcs.length; i++)
						for (core.game.Observation obs : npcs[i])
							//Guardamos la posicion de los enemigos
							pos_enemigos.add(new Vector2d((int)(obs.position.x/this.blockSize), (int)(obs.position.y/this.blockSize)));
					
					//Recorremos las posiciones de los enemigos hasta comprobar todos o encontrar del que huir
					for(int i = 0; i < pos_enemigos.size() && !huyo; i++)	                	
			        	huyo = debo_huir(avatar, pos_enemigos.get(i));
			        	
					//Si tengo que huir de algun enemigo
					if(huyo){
						
						//El nivel debe ser reactivo simple
						nivel_actual = nivel.REACTIVO_SIMPLE;
						//Cambiamos el camino
						cambiar_recorrido = true;
						
					}
					
				}
				//Si no hay gemas pero hay un enemigo es reactivo simple
				else if(npcs[0].size() == 1) nivel_actual = nivel.REACTIVO_SIMPLE;
				//Si no hay gemas pero hay mas de un enemigo es reactivo compuesto
				else if(npcs[0].size() >1 )nivel_actual = nivel.REACTIVO_COMPUESTO;
						
			}
		
		//Si el numero de gemas recogidas por ahora aun no es 9
		}else if(n_gems < 9){
			
			//Establezco el nivel a deliberativo compuesto
			nivel_actual = nivel.DELIBERATIVO_COMPUESTO;
			//Si hay enemigos en el mapa
			if(npcs != null) {
				
				//En un principio no huyo
				huyo = false;
				//Borro los enemigos que tenga almacenados
				pos_enemigos.clear();
				//Recorro los enemigos
				for (int i = 0; i < npcs.length; i++)
					for (core.game.Observation obs : npcs[i])
						//Almaceno la posicion de todos ellos
						pos_enemigos.add(new Vector2d((int)(obs.position.x/this.blockSize), (int)(obs.position.y/this.blockSize)));
				
				//Recorro la posicion de los enemigos hasta encontrar alguno del que huyo o comprobarlos todos
				for(int i = 0; i < pos_enemigos.size() && !huyo; i++)                 	
                	huyo = debo_huir(avatar, pos_enemigos.get(i));
                	
				//Si encuentro alguno del que huir
				if(huyo)	nivel_actual = nivel.REACTIVO_SIMPLE;
									
			}
			
		}
		
	}
}
