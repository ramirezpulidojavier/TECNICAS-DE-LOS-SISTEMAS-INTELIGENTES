package src_Ramirez_Pulido_Javier;

import java.util.ArrayList;

import ontology.Types;
import ontology.Types.ACTIONS;
import src_Ramirez_Pulido_Javier.Esquivar.orientacion;
import tools.Vector2d;

import core.game.StateObservation;
import core.game.Observation;

import javax.swing.plaf.nimbus.State;

/**
 * Created by Javier Ramirez Pulido on 12/04/21.
 */
public class Esquivar
{
	
	//Enum con las 4 orientaciones posibles para facilitar su manejo
	public enum orientacion{
        Norte, Sur, Este, Oeste;
    }
	
	//Matriz con el mapa del juego
    ArrayList<core.game.Observation> matriz_mapa[][];
    //Vector con las posiciones de los enemigos
    ArrayList<Vector2d> enemies;
    //State que tiene la informacion del sistema en cada momento
    StateObservation actual_state;
    //Variable necesaria para obtener la posicion de los enemigos en escala con el mapa
    int blockSize;
    //Objeto PathFinder para realizar A*
    PathFinder pf;

    //Constructor 
    //stateObs: contiene la informacion del mapa del juego y del tamaño de bloque para hacer la escala 
    public Esquivar(StateObservation stateObs){
    	
        this.matriz_mapa = stateObs.getObservationGrid();
        enemies = new ArrayList<Vector2d>();
        actual_state = stateObs;
        this.blockSize = stateObs.getBlockSize();
        pf = new PathFinder();
		pf.run(stateObs);

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
    
    
    //Funcion para esquivar a los enemigos. Sirve para uno o para varios
  	//avatar: coordenadas del avatar
  	//orientation: orientacion del avatar
  	//enemigo: vector con la posicion de los enemigos
    public ArrayList<Types.ACTIONS> huir(Vector2d avatar, orientacion orientation, ArrayList<Vector2d> enemigo ){
    	
    	//Vector de acciones a realizar para huir del enemigo. Puede ser un paso o dos si tiene que girar
        ArrayList<Types.ACTIONS> actions = new ArrayList<Types.ACTIONS>();
        //Obtenemos la posicion del centro porque debemos priorizar avanzar hacia espacios abiertos, pues encerrado aumentan las chances de morir
        Vector2d pos_centro = new Vector2d(matriz_mapa.length/2, matriz_mapa[0].length/2);

        //Vector que contendra la evaluacion de cada nodo. Estos se evaluan para saber cual es la mejor opcion en la huida
        int alrededor[] = {0,0,0,0};
        //Contendra las coordenadas de cada vecino que evaluemos para conocer hacia donde nos movemos
        Vector2d auxiliar = new Vector2d(0,0);
        //Tenemos un valor minimo para buscar entre los vecinos el que tenga la mejor valoracion 
        int mayor = Integer.MIN_VALUE;
        //Variable que contendra el indice del vecino que mejor evaluacion tiene
        int vecino_mayor = 0;
        //Accion que devolveremos como correcta para huir, inicialmente nula
        Types.ACTIONS action = Types.ACTIONS.ACTION_NIL;
        //El numero de acciones por defecto a realizar sera 1, solamente seran 2 cuando tenga que girar+avanzar
        int n_actions = 1;
        
        
        //---------------------------Evaluamos la casilla de arriba---------------------------
        auxiliar.x = avatar.x;
    	auxiliar.y = avatar.y-1;
    	
    	//Si el vecino de arriba esta vacio
        if(this.matriz_mapa[(int) avatar.x][(int) avatar.y-1].isEmpty())
        	//Evaluamos cómo de conveniente es ir hacia el
			alrededor[0] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 0);
	    
        //Si no esta vacio pero al menos no es un muro, lo evaluamos tambien
        else if(this.matriz_mapa[(int)avatar.x][(int)avatar.y-1].get(0).itype != 0) 
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[0] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 0);
        
        //Si lo que hay es un muro ponemos el valor minimo para asegurarnos de que no lo considere como posicion a la que huir
        else  	alrededor[0]=Integer.MIN_VALUE;
       
        
        //---------------------------Evaluamos la casilla de debajo---------------------------
        auxiliar.x = avatar.x;
    	auxiliar.y = avatar.y+1;
    	
    	//Si el vecino de debajo esta vacio
        if(this.matriz_mapa[(int) avatar.x][(int) avatar.y+1].isEmpty())
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[1] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 1);
	     
        //Si no esta vacio pero al menos no es un muro, lo evaluamos tambien
        else if(this.matriz_mapa[(int)avatar.x][(int)avatar.y+1].get(0).itype != 0)
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[1] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 1);
        
        //Si lo que hay es un muro ponemos el valor minimo para asegurarnos de que no lo considere como posicion a la que huir
        else   	alrededor[1]=Integer.MIN_VALUE;
        
        
        
      //---------------------------Evaluamos la casilla de la derecha---------------------------
        auxiliar.x = avatar.x+1;
    	auxiliar.y = avatar.y;
    	
    	//Si el vecino de la derecha esta vacio
        if(this.matriz_mapa[(int) avatar.x+1][(int) avatar.y].isEmpty())
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[2] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 2);
      
        //Si no esta vacio pero al menos no es un muro, lo evaluamos tambien    	
        else if(this.matriz_mapa[(int)avatar.x+1][(int)avatar.y].get(0).itype != 0) 
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[2] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 2);
        
        //Si lo que hay es un muro ponemos el valor minimo para asegurarnos de que no lo considere como posicion a la que huir
        else   	alrededor[2]=Integer.MIN_VALUE;
        
        
      //---------------------------Evaluamos la casilla de la izquierda---------------------------
        auxiliar.x = avatar.x-1;
    	auxiliar.y = avatar.y;
      
    	//Si el vecino de la izquierda esta vacio
        if(this.matriz_mapa[(int) avatar.x-1][(int) avatar.y].isEmpty())
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[3] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 3);
      
        //Si no esta vacio pero al menos no es un muro, lo evaluamos tambien
        else if(this.matriz_mapa[(int)avatar.x-1][(int)avatar.y].get(0).itype != 0)
        	//Evaluamos cómo de conveniente es ir hacia el
        	alrededor[3] = evaluacion_vecino(avatar, pos_centro, auxiliar, orientation, enemigo, 3);
        
        //Si lo que hay es un muro ponemos el valor minimo para asegurarnos de que no lo considere como posicion a la que huir
        else     alrededor[3]=Integer.MIN_VALUE;
        
        
        //Una vez evaluados los 4 vecinos, buscamos entre ellos el que mejor evaluacion tenga
        int i = 0;
        while(i<alrededor.length) {
        	//Si la evaluacion de este vecino es mejor que la mejor, la guardo
        	if(alrededor[i]> mayor) {
        		//Actualizo la mejor evaluacion
        		mayor = alrededor[i];
        		//Guardo el vecino al que debo ir
        		vecino_mayor = i;
        	}
        	//avanzamos las iteraciones
        	i++;
        }
        
        
        switch (vecino_mayor){
        	
        	case 0: //Si el mejor vecino es el de arriba
        	  
        		//Si no esta mirando hacia arriba el avatar
        		if(orientation!=orientacion.Norte)
        			//Tendra que hacer dos acciones, girar y avanzar
        			n_actions = 2;
              
        		//La accion es ir hacia arriba
        		action = Types.ACTIONS.ACTION_UP;
              
        		break;
              
        	case 1: //Si el mejor vecino es el de abajo
             
				//Si no esta mirando hacia abajo el avatar
				if(orientation!=orientacion.Sur)
					//Tendra que hacer dos acciones, girar y avanzar
					n_actions = 2;
				  
				//La accion es ir hacia abajo
				action = Types.ACTIONS.ACTION_DOWN;
			  
				break;
              
        	case 2: //Si el mejor vecino es el de la derecha
		
        		//Si no esta mirando hacia la derecha el avatar
        		if(orientation!=orientacion.Este)
        			//Tendra que hacer dos acciones, girar y avanzar
        			n_actions = 2;
			  
        		//La accion es ir hacia la derecha
        		action = Types.ACTIONS.ACTION_RIGHT;
			  
        		break;

        	case 3: //Si el mejor vecino es el de la izquierda
              
        		//Si no esta mirando hacia la izquierda el avatar
        		if(orientation!=orientacion.Oeste)
        			//Tendra que hacer dos acciones, girar y avanzar
        			n_actions = 2;
              
        		//La accion es ir hacia la izquierda
        		action = Types.ACTIONS.ACTION_LEFT;
              
        		break;

        }
        
        //Añado tantas acciones como haga falta. Sera 1 si esta delante y dos si tiene que girar
        for(int j=0; j < n_actions; j++)
            actions.add(action);
        
        return actions;
        
    }
    

    
    //Funcion que comprueba si una posicion es una esquina para evitar cuando sea posible
    //casilla: posicion que vamos a comprobar si es esquina o no
    private boolean es_esquina(Vector2d casilla){
    	
    	//Si la posicion de la izquierda es no esta vacia
		if(!this.matriz_mapa[(int) casilla.x-1][(int) casilla.y].isEmpty() ) {
			//Si ademas de no estar vacia, es muro
			if(this.matriz_mapa[(int)casilla.x-1][(int)casilla.y].get(0).itype == 0) {
				//Es esquina si arriba o abajo hay muro tambien
				//Si la posicion de arriba no esta vacia
				if(!this.matriz_mapa[(int) casilla.x][(int) casilla.y-1].isEmpty()) {
					//Si ademas de no estar vacia es un muro
					if(this.matriz_mapa[(int)casilla.x][(int)casilla.y-1].get(0).itype == 0) {
						//es esquina
						return true;
					}
			    //Si la posicion de arriba no esta vacia
				}else if(!this.matriz_mapa[(int) casilla.x][(int) casilla.y+1].isEmpty()) {
					//Si ademas de no estar vacia es un muro
					if(this.matriz_mapa[(int)casilla.x][(int)casilla.y+1].get(0).itype == 0) {
						//es esquina
						return true;
					}
				}
			}
				
		}else //Si la posicion de la derecha es no esta vacia
			if(!this.matriz_mapa[(int) casilla.x+1][(int) casilla.y].isEmpty() ) {
				//Si ademas de no estar vacia, es muro
				if(this.matriz_mapa[(int)casilla.x+1][(int)casilla.y].get(0).itype == 0) {
					//Es esquina si arriba o abajo hay muro tambien
					//Si la posicion de arriba no esta vacia
					if(!this.matriz_mapa[(int) casilla.x][(int) casilla.y-1].isEmpty()) {
						//Si ademas de no estar vacia es un muro
						if(this.matriz_mapa[(int)casilla.x][(int)casilla.y-1].get(0).itype == 0) {
							//es esquina
							return true;
						}
				    //Si la posicion de arriba no esta vacia
					}else if(!this.matriz_mapa[(int) casilla.x][(int) casilla.y+1].isEmpty()) {
						//Si ademas de no estar vacia es un muro
						if(this.matriz_mapa[(int)casilla.x][(int)casilla.y+1].get(0).itype == 0) {
							//es esquina
							return true;
						}
					}
				}
					
			}
		
		//Si llega hasta aqui es porque no era una esquina
		return false;
			
	}

    
    //Actualiza la posicion de los enemigos
    public void updateEnemies(StateObservation stateObs)
    {
    	//Vaciamos el vector de enemigos por si contiene alguno
        enemies.clear();
        //Obtenemos la posicion de los enemigos
        ArrayList<core.game.Observation>[] npcs = stateObs.getNPCPositions();
        
        //Si hay algun enemigo
        if(npcs!=null) {
        	//Recorro el vector de enemigos
        	for (int i = 0; i < npcs.length; i++)
                for (core.game.Observation obs : npcs[i])
                	//Añado las coordenadas del enemigo al vector de coordenadas
                    enemies.add(new Vector2d((int)(obs.position.x/this.blockSize), (int)(obs.position.y/this.blockSize)));
                
            
        }
        
    }
    
    //Funcion que evalua que tan buena es una posicion para huir hacia ella
    //avatar: posicion del avatar
    //pos_centro: posicion del centro
    //auxiliar: posicion vecino que estamos evaluando
    //orientacion: orientacion del personaje
    //enemigo: vector con las posiciones de los escorpiones
    //dir: indice del vecino que estoy evaluando
    private int evaluacion_vecino(Vector2d avatar, Vector2d pos_centro, Vector2d auxiliar, orientacion orientation, ArrayList<Vector2d> enemigo, int dir) {
    	
    	//Evaluacion contendra la 'nota' que tiene este nodo como opcion para huir
    	int evaluacion = 0;
    	
    	//Sumo un punto extra si el nodo que evaluo esta delante de mi (evito perder un tick en un giro)
    	switch(dir) {
    		case 0: //Si es el nodo del norte y miro hacia arriba
    			if(orientation == orientacion.Norte) evaluacion++;break;
    		case 1: //Si es el nodo del sur y miro hacia abajo
    			if(orientation == orientacion.Sur) evaluacion++;break;
    		case 2: //Si es el nodo de la derecha y miro hacia la derecha
    			if(orientation == orientacion.Este) evaluacion++;break;
    		case 3: //Si es el nodo de la izquierda y miro hacia la izquierda
    			if(orientation == orientacion.Oeste) evaluacion++;break;
    		
    	}
    	
    	//Miro para cada enemigo por si me estoy acercando a uno mientras huyo de otro o ver si estoy huyendo del que debo
    	for(int i  = 0 ; i < enemigo.size(); i++) {
    		//Si este nodo esta mas cerca del enemigo actual
			if(manhattan(avatar, enemigo.get(i)) > manhattan(auxiliar, enemigo.get(i))) {
				//Se evalua negativamente pero inversamente proporcional a la distancia para tener en cuenta que si 
				//huyendo de uno me acerco a otro puede convenirme siempre y cuando este lo suficientemente lejos
				evaluacion -= (6-manhattan(auxiliar, enemigo.get(i)));
			
			//Si este nodo esta mas lejos del enemigo evaluo positivamente el movimiento 
			}else evaluacion += 2;
			
		}
    	
    	//Si ademas se acerca al centro
    	if(manhattan(avatar, pos_centro) > manhattan(auxiliar, pos_centro)) {
    		//Punto extra porque siempre conviene ir a los sitios menos arrinconados posibles
    		evaluacion++;
    	//Si me aleja del centro (y por tanto me acerca a una pared o esquina) se evalua negativamente
    	}else evaluacion--;
    	
    	//Si el nodo al que vamos es esquina se evalua negativamente para que solo vaya si no le queda otra
    	if(es_esquina(auxiliar)) evaluacion--;
		    	
    	//Devuelve la nota de esa posicion
    	return evaluacion;
    	
    }
    
    //Funcion manhattan para obtener la distancia entre dos nodos
    //node: Nodo de origen desde el que calcular la distancia
    //goal: Nodo de destino hacia el que calcular la distancia
	private int manhattan(Vector2d node, Vector2d goal){
		
		return (int) (Math.abs(node.x - goal.x) + Math.abs(node.y - goal.y));
	
	}
    
}