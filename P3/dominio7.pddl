(define (domain ejercicio_7)
    (:requirements :strips :adl :fluents)

    (:types
        
        elementos_mapa - object   ; Elementos del mapa son tanto unidades como edificios
        coordenadas - object      ; Coordenadas son posiciones del mapa (3x4)
        recursos_entorno - object ; Recursos del mapa
        
        unidad - elementos_mapa    ; Diferenciamos que un elemento del mapa puede ser una unidad
        edificio - elementos_mapa  ; Diferenciamos que un elemento del mapa puede ser un edificio
        
        nombre_edificio - edificio                  ; Tipo concreto para las constantes de edificio
        nombre_unidad - unidad                      ; Tipo concreto para las constantes de unidad
        nombre_recursos_entorno - recursos_entorno  ; Tipo concreto para las constantes de recurso
    )

    (:constants

        VCE Marines Segadores - nombre_unidad                   ; Constantes de unidades para todo el problema 

        CentroDeMando Barracones Extractores - nombre_edificio  ; Constantes de edificios para todo el problema 

        Mineral Gas - nombre_recursos_entorno                   ; Constantes de recursos para todo el problema 

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
        (requiere_recurso_tipo ?elemnto_mapa - elementos_mapa ?nombre_recurs_entorno - nombre_recursos_entorno) 

    )


    ; funciones para trabajar con predicados numericos 
    (:functions

        ; guarda la cantidad de un recurso concreto que necesita un elemento del mapa (entidad o edificio)
        (funcion_requiere_recurso ?elemnto_mapa - elementos_mapa ?nombre_recurs_entorno - nombre_recursos_entorno)

        ; guarda la cantidad que tenemos almacenada de un recurso concreto (mineral o gas)
        (cantidad_de_recurso_tipo ?nombre_recurs_entorno - nombre_recursos_entorno)

        ; guarda la cantidad maxima que podemos llegar a tener almacenado de un recurso concreto (mineral o gas)
        (capacidad_maxima_recurso_tipo ?nombre_recurs_entorno - nombre_recursos_entorno)

        ; guarda la cantidad de vce's que hay por cada material
        ; como mucho habra un trabajador en un nodo de gas (solo hay uno)
        ; como mucho habra dos trabajadores en un nodo de mineral (solo hay dos)
        ; si hay dos trabajadores en un nodo, no recolecta 10, sino 20, y eso hay que controlarlo
        (unidades_por_nodo_recurso_tipo ?nombre_recurs_entorno - nombre_recursos_entorno)

        ; guarda el tiempo que consume el reclutamiento de una unidad o la construccion de un edificio
        (cantidad_tiempo_requiere ?ent - elementos_mapa)

        ; velocidad de cada unidad
        (velocidad_unidad_tipo ?tUnid - nombre_unidad)

        ; guarda la suma total del tiempo que consumen todas las acciones que se realizan. Es el objetivo a minimizar
        (tiempoTrascurrido)        

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

                ; segun la unidad que se haya movido, aumenta el tiempo tanto como tarde este tipo de unidad en dar un paso
                (forall (?r - nombre_unidad)
                    (when (unidad_de_tipo ?unidd ?r)
                        (increase
                            (tiempoTrascurrido)             
                            (/
                                10   
                                (velocidad_unidad_tipo ?r)
                            )
                        )  
                    )
                )

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

                ; cuando recolectamos un material necesitamos saber de cuantos nodos a la vez para recolectar 
                ; proporcionalmente, por lo que por cada unidad que pongamos a recolectar un recurso, aumentamos la 
                ; cuenta de la de trabajadores que hay sacando este recurso
                (increase
                    (unidades_por_nodo_recurso_tipo ?recurs_entorno)
                    1
                )

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

                ; solo puede haber un edificio en cada nodo del mapa
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

                
                ; tenemos que tener suficiente de cada recurso que necesita antes de construir un edificio 
                (and 
                    (exists (?t - nombre_edificio)  ;existe al menos un tipo de edificio
                        (and
                     
                            (edificio_de_tipo ?edifcio ?t) ;que sea el tipo de edifico que vamos a construir
                        
                            ;y tengamos tanto mineral como este tipo de edificios necesita o mas
                            (>=                                                 
                                (cantidad_de_recurso_tipo Mineral)
                                (funcion_requiere_recurso ?t Mineral)
                            )
                        )
                    )

                    (exists (?t - nombre_edificio)  ;existe al menos un tipo de edificio
                        (and
                     
                            (edificio_de_tipo ?edifcio ?t) ;que sea el tipo de edifico que vamos a construir
                        
                            ;y tengamos tanto gas como este tipo de edificios necesita o mas
                            (>=                                                 
                                (cantidad_de_recurso_tipo Gas)
                                (funcion_requiere_recurso ?t Gas)
                            )
                        )
                    )

                )

            )
      :effect
            (and
                ; le asignamos una localizacion al edificio en el mapa una vez es construido
                (elemento_mapa_en ?edifcio ?coord)

                ; para que tenga en cuenta segun el tipo de edificio que sea cuanto recurso o tiempo gasta construyendo
                (forall (?r - nombre_edificio)
                    (when (edificio_de_tipo ?edifcio ?r) ; cuando se cumpla que el edificio que construimos es de un tipo
                        (and  

                            ; restamos a la cantidad de mineral que tenemos la que necesita este tipo de edificio concreto
                            (decrease
                                (cantidad_de_recurso_tipo Mineral)
                                (funcion_requiere_recurso ?r Mineral)
                            )

                            ; restamos a la cantidad de gas que tenemos la que necesita este tipo de edificio concreto     
                            (decrease
                                (cantidad_de_recurso_tipo Gas)
                                (funcion_requiere_recurso ?r Gas)
                            )

                            ; sumamos al tiempo total el tiempo que necesita este edificio para ser construido
                            (increase
                                (tiempoTrascurrido)
                                (cantidad_tiempo_requiere ?r)
                            )
                        )   
                    )
                )

                ; indicamos que este edificio, ya que ha sido construido, no necesita ser construido ya
                (not (por_construir ?edifcio))               

            )

    )

    ; Accion para reclutar unidades nuevas 
    ; edifcio -> edificio del que se recluta la unidad concreta. Diferentes unidades se reclutan de diferentes edificios
    ; unidd -> unidad que vamos a reclutar 
    ; coord -> posicion del mapa en la que esta el edificio del que reclutamos la unidad y el lugar en el que aparece la 
    ; unidad
    (:action reclutar
        :parameters (?edifcio - edificio ?unidd - unidad ?loc - coordenadas)
        :precondition
            (and
                
                ; tenemos que tener suficiente material de cada tipo para poder reclutar esa unidad
                (exists (?tuni - nombre_unidad)
                    (and (unidad_de_tipo ?unidd ?tuni)
                         (>= (cantidad_de_recurso_tipo Mineral) (funcion_requiere_recurso ?tuni Mineral))
                         (>= (cantidad_de_recurso_tipo Gas) (funcion_requiere_recurso ?tuni Gas))
                    )
                )

                ; en la posicion del mapa en la que vamos a reclutar debe haber un edificio del tipo que necesitemos
                (elemento_mapa_en ?edifcio ?loc)

                ; la forma de saber que esa unidad no ha sido reclutada aun es que no tenga coordenadas asignadas
                (not (exists (?l - coordenadas) (and  (elemento_mapa_en ?unidd ?l)) ) )

                ; Si la unidad es de tipo VCE el edificio tiene que ser un centro de mando o la unidad es de cualquier
                ; otro tipo y el edificio tiene que ser un barracon
                (or 
                    (and 
                        (unidad_de_tipo ?unidd VCE) 
                        (edificio_de_tipo ?edifcio CentroDeMando)
                    )
                    (and 
                        (or 
                            (unidad_de_tipo ?unidd Marines) 
                            (unidad_de_tipo ?unidd Segadores)
                        ) 
                        (edificio_de_tipo ?edifcio Barracones)
                    )
                )

            )

        :effect
            ( and
                ; asignamos coordenadas a la unidad reclutada que coincide con la posicion del edificio del que se recluta
                (elemento_mapa_en ?unidd ?loc)

                ; indicamos que una unidad en cuanto es reclutada esta libre 
                (unidad_disponible ?unidd)

                ; vamos a actualizar los recursos despues de consumir los necesarios en el reclutamiento
                (forall (?r - nombre_unidad) 

                    (when (unidad_de_tipo ?unidd ?r) ; cuando se cumpla que la unidad que reclutamos es de un tipo
                        (and  

                            ; restamos a los minerales que teniamos almacenados tantos como necesitemos para reclutar este 
                            ; tipo de unidad
                            (decrease
                                (cantidad_de_recurso_tipo Mineral)
                                (funcion_requiere_recurso ?r Mineral)
                            )

                            ; restamos al gas que teniamos almacenados tantos como necesitemos para reclutar este 
                            ; tipo de unidad
                            (decrease
                                (cantidad_de_recurso_tipo Gas)
                                (funcion_requiere_recurso ?r Gas)
                            )

                            ; sumamos al tiempo total el que nos consume el reclutamiento de este tipo de unidades
                            (increase
                                (tiempoTrascurrido)
                                (cantidad_tiempo_requiere ?r)
                            )
                        )   
                    )
                )

            )

    )


    ; Accion para extraer 10 unidades de recurso del nodo de algun tipo de material que se este recolectando
    ; recurs_entorno -> recurso del que vamos a extraer 10 unidades
    ; coord -> posicion del mapa en la que esta el nodo de recurso del que vamos a recolectar 10 unidades de materiales
    (:action recolectar
        :parameters (?recurs_entorno - recursos_entorno ?coord - coordenadas)
        :precondition
            (and
    
                ;debe haber un nodo de recurso en esa posicion y ser del tipo de recurso que vamos a recolectar            
                (nodo_recurso_entorno_en ?recurs_entorno ?coord)

                ; se le debe haber asignado algun nodo de este tipo de recurso a al menos un VCE, por lo que ya se
                ; estara extrayendo este recurso
                (recolectando_recurso_entorno ?recurs_entorno)

                ; antes de recolectar tenemos que comprobar que al hacerlo no vamos a superar los limites de ese 
                ; material.
                (<=
                    (cantidad_de_recurso_tipo ?recurs_entorno)
                    (- (capacidad_maxima_recurso_tipo ?recurs_entorno) 
                        (*
                            10
                            (unidades_por_nodo_recurso_tipo ?recurs_entorno)
                        )
                    )
                )

                ; existe al menos una unidad que sea de tipo VCE en esa coordenada y que no este libre. Con esto evitamos
                ; el vacio legal de que se este extrayendo Mineral de LOC23 y cuando recolectemos lo haga de LOC33
                (exists (?unid - unidad)
                        (and 
                            (unidad_de_tipo ?unid VCE) 
                            (elemento_mapa_en ?unid ?coord)
                            (not (unidad_disponible ?unid))
                       ) 
                )

            )


        :effect
            (and
                
                ;Al recolectar de un material, la cantidad almacenada de este aumenta en 10 unidades
                (increase
                    (cantidad_de_recurso_tipo ?recurs_entorno)
                    (*
                        10
                        (unidades_por_nodo_recurso_tipo ?recurs_entorno)
                    )
                )

                ; Sumamos al tiempo total el tiempo consumido en la recoleccion de este material
                (increase
                    (tiempoTrascurrido)
                    10
                )
            )
    )

)