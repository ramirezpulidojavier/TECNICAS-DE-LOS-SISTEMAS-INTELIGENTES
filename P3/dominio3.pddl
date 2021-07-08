(define (domain ejercicio_3)
	(:requirements :strips :adl :fluents)

	(:types
        
        elementos_mapa - object   ; Elementos del mapa son tanto unidades como edificios
        coordenadas - object      ; Coordenadas son posiciones del mapa (3x4)
        recursos_entorno - object ; Recursos del mapa
        
        unidad - elementos_mapa    ; Diferenciamos que un elemento del mapa puede ser una unidad
        edificio - elementos_mapa  ; Diferenciamos que un elemento del mapa puede ser un edificio
        
        nombre_edificio - edificio                 	; Tipo concreto para las constantes de edificio
        nombre_unidad - unidad 						; Tipo concreto para las constantes de unidad
        nombre_recursos_entorno - recursos_entorno  ; Tipo concreto para las constantes de recurso
    )

    (:constants

        VCE - nombre_unidad                 					; Constantes de unidades para todo el problema 

        CentroDeMando Barracones Extractores - nombre_edificio	; Constantes de edificios para todo el problema 

        Mineral Gas - nombre_recursos_entorno					; Constantes de recursos para todo el problema 

    )

	(:predicates

    	; diponibilidad de una unidad para poder moverla o aignarle alguna tarea en un momento dado
        ; si una unidad no pertenece a un predicado así directamente se da por ocupada, no existe un 'no_disponible'
        (unidad_disponible ?unidd - unidad)

        ; indica que un edicio aun no ha sido construido en el mapa, condicion necesaria para no construir repetidos
        (por_construir ?edfcio - edificio)

        ; guarda la posicion del mapa en la que se encuentra un edificio o unidad
        (elemento_mapa_en ?elemnto_mapa - elementos_mapa ?coord - coordenadas)

        ; para indicar si un recurso esta siendo obtenido, ya sea mineral o gas 
        (recolectando_recurso_entorno ?recurs_entorno - recursos_entorno)

        ; guarda a que tipo pertenece un edificio concreto (Por ejemplo, Barracones1 es de tipo Barracones)
        (edificio_de_tipo ?edfcio - edificio ?nombre_edfcio - nombre_edificio)

        ; existe para cada par de nodos del mapa que estan conectados directamente
        ; Al parecer es dirigido, por lo que para predicados asi, el camino es desde x1 hacia x2 y no al reves
        (conexion_nodos_mapa ?coord1 - coordenadas ?coord2 - coordenadas)

        ; para indicar la posicion en la que se encuentra un nodo de recurso del entorno, ya sea mineral o gas
        (nodo_recurso_entorno_en ?recurs_entorno - recursos_entorno ?coord - coordenadas)

        ; guarda a que tipo pertenece una unidad concreta (Por ejemplo, VCE1 es de tipo VCE)
        (unidad_de_tipo ?unidd - unidad ?nombre_unidd - nombre_unidad)

        ; almacena que tipo de recurso es necesario estar obteniendo antes de construir un edificio concreto
        (requiere_recurso_tipo ?nombre_edfcio - nombre_edificio ?rec - nombre_recursos_entorno) 

    )

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ACCIONES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Accion para mover una unidad de cualquier tipo desde un origen a un destino
    ; unidd -> Unidad que vamos a mover (VCE1, VCE2, MARINE1,...)
    ; coord1 -> posicion en la que se encuentra antes de moverse
    ; coord2 -> posicion en la que se encuentra despues de moverse. Debe existir una conexion entre coord1 y coord2
    ; porque la accion mueve la unidad unicamente un paso entre nodos directamente conectados
    (:action navegar
      :parameters (?unidd - unidad ?coord1 ?coord2 - coordenadas)
      :precondition
            (and

            	; si una unidad esta recolectando algun tipo de recurso no se puede mover de este
                (unidad_disponible ?unidd)
                ; la unidad antes de moverse debe encontrarse en la coordenada que indicamos como origen del movimiento
                (elemento_mapa_en ?unidd ?coord1)
                ; debe existir un enlace directo entre el nodo de origen y destino porque solo realizamos un paso
                (conexion_nodos_mapa ?coord1 ?coord2)
                
            )

      :effect
            (and

                ; tras la accion la unidad se encuentra en la coordenada de destino
                (elemento_mapa_en ?unidd ?coord2)

                ; por tanto ya no se encuentra en la coordenada de origen
                (not (elemento_mapa_en ?unidd ?coord1))

            )
            
    )

	; Accion para asignar un VCE a un nodo de recurso para que extraiga este
    ; unidd -> VCE que vamos a poner a extraer el recurso
    ; coord -> posicion en la que se encuentra el recurso que vamos a extraer
    ; recurs_entorno -> tipo de recurso que se encuentra en esa posicion y que vamos a extraer
    (:action asignar
      :parameters (?unidd - unidad ?coord - coordenadas ?recurs_entorno - recursos_entorno)
      :precondition
            (and

            	; la unidad debe ser del tipo VCE porque ni los marines ni los segadores recolectan recursos
                (unidad_de_tipo ?unidd VCE)

                ; este VCE no debe estar recolectando otro recurso
                (unidad_disponible ?unidd)

                ; el VCE tiene que estar en las coordenadas en las que le vamos a poner a extraer
                (elemento_mapa_en ?unidd ?coord)

                ;en la localizacion en la que pondremos al VCE a extraer debe haber un nodo del recurso que vamos a extraer
                (nodo_recurso_entorno_en ?recurs_entorno ?coord)                 

                ;o el nodo no es de gas o de serlo, debe existir al menos un edificio de tipo extractor en esas coordenadas
                (or
                    (exists (?e - edificio)
                            (and 
                            	(elemento_mapa_en ?e ?coord)
                            	(edificio_de_tipo ?e Extractores)
                            )
                    )
                    (not (nodo_recurso_entorno_en Gas ?coord))
                )       

            )

      :effect

            (and

                ; Cuando el vce empieza a extraer un recurso deja de estar libre (ya no hace otra cosa)
                (not (unidad_disponible ?unidd))


                ; este recurso empieza a ser recolectado por lo que se puede usar para construcciones y reclutamientos
                (recolectando_recurso_entorno ?recurs_entorno)

            )

    )

    ; Accion para construir un edificio en una localizacion del mapa
    ; unidd -> VCE que va a construir el edificio (es de tipo unidad por lo que podria ser tambien marine o segador pero
    ; solamente los vces van a construir edificios)
    ; edifcio -> edificio que vamos a construir en esas coordenadas
    ; coord -> posicion del mapa en la que vamos a construir el edificio
    (:action construir
      :parameters (?unidd - unidad ?edifcio - edificio ?coord - coordenadas)
      :precondition
            (and

            	; necesitamos que el edificio que vamos a construir aun este por construir para no repetir edificios en el 
                ; mapa (si se pueden repetir tipos, pero no instancias concretas. Varios Barracones si, Varios Barracones1 ; no)
                (por_construir ?edifcio)

            	; la unidad debe ser del tipo VCE porque ni los marines ni los segadores recolectan recursos
                (unidad_de_tipo ?unidd VCE)

                ; este VCE no debe estar recolectando otro recurso
                (unidad_disponible ?unidd)

                ; el VCE tiene que estar en las coordenadas en las que le vamos a poner a extraer
                (elemento_mapa_en ?unidd ?coord)

                ; solo puede haber un edificio en cada nodo del mapa. Que no haya un edificio construido en esta posicion
                (forall (?r - edificio)    ; para cada edificio
                    (or 
                    	(por_construir ?r) ; o no esta construido
                        (and 
                        	(not (por_construir ?r)) ; o si esta construido
                        	(not (elemento_mapa_en ?r ?coord)) ; pero tiene que ser en otro lado donde no vayamos a construir
                        ) 
                    )
                )

                ; los extractores solamente pueden construirse sobre un nodo en el que haya el recurso gas por lo que
                ; o no es un extractor o si lo es pero en esa posicion hay un nodo de gas
                (or 
                	(and 
                		(nodo_recurso_entorno_en Gas ?coord) 
                		(edificio_de_tipo ?edifcio Extractores) 
                	)
                    (not (edificio_de_tipo ?edifcio Extractores))
                )


                ; tenemos que tener algun vce extrayendo cada recurso que necesite un edificio antes de construirlo 
                (and 
                	(exists (?t - nombre_edificio)  ;existe al menos un tipo de edificio
                    	(and
                     
                        	(edificio_de_tipo ?edifcio ?t) ;que sea el tipo de edifico que vamos a construir
                        
                        	;si ese edificio necesita Mineral tenemos que tener algun vce extrayendolo ya
                        	(imply (requiere_recurso_tipo ?t Mineral) (recolectando_recurso_entorno Mineral) )
                    	)
	                )

                    (exists (?t - nombre_edificio)  ;existe al menos un tipo de edificio
                    	(and
                     
                        	(edificio_de_tipo ?edifcio ?t) ;que sea el tipo de edifico que vamos a construir
                        
                        	;si ese edificio necesita Gas tenemos que tener algun vce extrayendolo ya
                        	(imply (requiere_recurso_tipo ?t Gas) (recolectando_recurso_entorno Gas) )
                    	)
	                )

                )
                
                

            )
      :effect
            (and
                ; le asignamos una localizacion al edificio en el mapa una vez es construido
                (elemento_mapa_en ?edifcio ?coord)

                ; indicamos que este edificio, ya que ha sido construido, no necesita ser construido ya
                (not (por_construir ?edifcio))               

            )

    )


)