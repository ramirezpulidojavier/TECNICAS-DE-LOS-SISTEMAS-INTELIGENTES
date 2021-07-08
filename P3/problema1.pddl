(define (problem ejercicio1)

    (:domain ejercicio_1)

    (:objects
        ; Coordenadas del mapa. Cada LOCxy corresponde con el nodo que se encuentra en la posicion [x,y] de la matriz
        LOC11 LOC12 LOC13 LOC14 - coordenadas
        LOC21 LOC22 LOC23 LOC24 - coordenadas
        LOC31 LOC32 LOC33 LOC34 - coordenadas
        
        ; creamos los elementos que vamos a necesitar en este ejercicio
        CentroDeMando1 - edificio
        VCE1 - unidad
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
        (unidad_disponible VCE1)

        ; Definimos de que tipo es cada edificio del que vamos a hacer uso en el ejercicio (cada tipo tiene sus caract.)
        (edificio_de_tipo CentroDeMando1 CentroDeMando)

        ; Definimos de que tipo es cada unidad de la que vamos a hacer uso en el ejercicio (cada tipo tiene sus caract.)
        (unidad_de_tipo VCE1 VCE)

        ; Definimos las posiciones del mapa fijas en las que se van a encontrar todos los nodos de los que extraer recursos
        (nodo_recurso_entorno_en Mineral LOC23)
        (nodo_recurso_entorno_en Mineral LOC33)

    )

    (:goal
        (and
            ; el objetivo es reclutar mineral
            (recolectando_recurso_entorno Mineral)
        )
    )
)