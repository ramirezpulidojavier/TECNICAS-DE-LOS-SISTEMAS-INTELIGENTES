(define (problem ejercicio6)

    (:domain ejercicio_6)

    (:objects
        ; Coordenadas del mapa. Cada LOCxy corresponde con el nodo que se encuentra en la posicion [x,y] de la matriz
        LOC11 LOC12 LOC13 LOC14 - coordenadas
        LOC21 LOC22 LOC23 LOC24 - coordenadas
        LOC31 LOC32 LOC33 LOC34 - coordenadas
        
        ; creamos los elementos que vamos a necesitar en este ejercicio
        CentroDeMando1 Extractor1 Barracones1 - edificio
        VCE1 VCE2 VCE3 - unidad
        Marine1 Marine2 Segador1 - unidad
    )

    (:init
        ; caminos directos del mapa. Tener en cuenta que en (conexion_nodos_mapa x y) se puede ir de x a y y no al reves
        (conexion_nodos_mapa LOC11 LOC12)
        (conexion_nodos_mapa LOC21 LOC11)
        (conexion_nodos_mapa LOC31 LOC21)
        (conexion_nodos_mapa LOC32 LOC31)
        (conexion_nodos_mapa LOC22 LOC32)
        (conexion_nodos_mapa LOC12 LOC22)
        (conexion_nodos_mapa LOC22 LOC23)
        (conexion_nodos_mapa LOC23 LOC13)
        (conexion_nodos_mapa LOC13 LOC14)
        (conexion_nodos_mapa LOC14 LOC24)
        (conexion_nodos_mapa LOC24 LOC34)
        (conexion_nodos_mapa LOC34 LOC33)
        (conexion_nodos_mapa LOC12 LOC11)
        (conexion_nodos_mapa LOC11 LOC21)
        (conexion_nodos_mapa LOC21 LOC31)
        (conexion_nodos_mapa LOC31 LOC32)
        (conexion_nodos_mapa LOC32 LOC22)
        (conexion_nodos_mapa LOC22 LOC12)
        (conexion_nodos_mapa LOC23 LOC22)
        (conexion_nodos_mapa LOC13 LOC23)
        (conexion_nodos_mapa LOC14 LOC13)
        (conexion_nodos_mapa LOC24 LOC14)
        (conexion_nodos_mapa LOC34 LOC24)
        (conexion_nodos_mapa LOC33 LOC34)

        ; Asignamos las coordenadas de aquellos elementos que ya empiezan situados en el mapa
        (elemento_mapa_en CentroDeMando1 LOC11)
        (elemento_mapa_en VCE1 LOC11)

        ;Indicamos la disponibilidad de las unidades que hay en el mapa
        (unidad_disponible VCE1)

        ; Definimos de que tipo es cada edificio del que vamos a hacer uso en el ejercicio (cada tipo tiene sus caract.)
        (edificio_de_tipo CentroDeMando1 CentroDeMando)
        (edificio_de_tipo Extractor1 Extractores)
        (edificio_de_tipo Barracones1 Barracones)

        ; Definimos de que tipo es cada unidad de la que vamos a hacer uso en el ejercicio (cada tipo tiene sus caract.)
        (unidad_de_tipo VCE1 VCE)
        (unidad_de_tipo VCE2 VCE)
        (unidad_de_tipo VCE3 VCE)
        (unidad_de_tipo Marine1 Marines)
        (unidad_de_tipo Marine2 Marines)
        (unidad_de_tipo Segador1 Segadores)

        ; Definimos las posiciones del mapa fijas en las que se van a encontrar todos los nodos de los que extraer recursos
        (nodo_recurso_entorno_en Mineral LOC23)
        (nodo_recurso_entorno_en Mineral LOC33)
        (nodo_recurso_entorno_en Gas LOC13)

        ; Indicamos los edificios que tienen que ser construidos a lo largo del ejercicio
        (por_construir Extractor1)
        (por_construir Barracones1)

        ; Definimos la cantidad de cada recurso que es necesaria para la construccion de cada tipo de edificio
        (= (funcion_requiere_recurso Barracones Mineral) 50)
        (= (funcion_requiere_recurso Barracones Gas) 20)
        (= (funcion_requiere_recurso Extractores Mineral) 33)
        (= (funcion_requiere_recurso Extractores Gas) 0)

        ; Definimos la cantidad de cada recurso que es necesaria para el reclutamiento de cada tipo de unidad
        (= (funcion_requiere_recurso VCE Mineral) 10)
        (= (funcion_requiere_recurso VCE Gas) 0)
        (= (funcion_requiere_recurso Marines Mineral) 20)
        (= (funcion_requiere_recurso Marines Gas) 10)
        (= (funcion_requiere_recurso Segadores Mineral) 30)
        (= (funcion_requiere_recurso Segadores Gas) 30)

        ; Inicializamos el maximo de cada recurso que podemos almacenar
        (= (capacidad_maxima_recurso_tipo Gas) 60)
        (= (capacidad_maxima_recurso_tipo Mineral) 60)

        ; Inicializamos la cantidad de cada recurso con la que empezamos el ejercicio, que de entrada es 0.
        (= (cantidad_de_recurso_tipo Gas) 0)
        (= (cantidad_de_recurso_tipo Mineral) 0)

        ; Cantidad de VCE's que tenemos trabajando en nodos de un mismo recurso, inicialmente 0
        (= (unidades_por_nodo_recurso_tipo Mineral) 0)
        (= (unidades_por_nodo_recurso_tipo Gas) 0)

    )

    (:goal
        (and
            ; El objetivo es colocar un marine en LOC31...
            (elemento_mapa_en Marine1 LOC31)
            ; ... otro marine en LOC24...
            (elemento_mapa_en Marine2 LOC24)
            ; ... y un segador en LOC12
            (elemento_mapa_en Segador1 LOC12)
            (elemento_mapa_en Barracones1 LOC32)
               
        )
    )
)