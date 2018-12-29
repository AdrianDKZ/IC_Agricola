(define (problem desarrollo) (:domain AGRICOLA)
  (:objects
  )
  (:init
    ;; Ronda y mecanismos de iteracion
      (ronda-actual UNO)
      (jugador-actual J1)
      (familiar_actual F1)
      (familiar_max-jugador J1 F2)
      (familiar_max-jugador J2 F2)
      (fase-ronda REPOSICION)
      (fase-partida RONDAS)
    ;; Elementos iniciales
      (= (huecos J1) 13)
      (= (huecos J2) 13)
      ;; Habitaciones
        (= (habitaciones J1) 2)
        (= (habitaciones J2) 2)
        (material_casa J1 MADERA)
        (material_casa J2 MADERA)
      ;; Recursos de los jugadores
  	    (= (recursos J1 ADOBE) 0)
  	    (= (recursos J1 JUNCO) 0)
  	    (= (recursos J1 MADERA) 0)
  	    (= (recursos J1 PIEDRA) 0)
  	    (= (recursos J1 JABALI) 0)
  	    (= (recursos J1 OVEJA) 0)
  	    (= (recursos J1 VACA) 0)
  	    (= (recursos J1 COMIDA) 0)
  	    (= (recursos J2 ADOBE) 0)
  	    (= (recursos J2 JUNCO) 0)
  	    (= (recursos J2 MADERA) 0)
  	    (= (recursos J2 PIEDRA) 0)
  	    (= (recursos J2 JABALI) 0)
  	    (= (recursos J2 OVEJA) 0)
  	    (= (recursos J2 VACA) 0)
  	    (= (recursos J2 COMIDA) 0)
      ;; Control de recursos acumulados
        (= (acumulado ADOBE) 0)
        (= (acumulado JUNCO) 0)
        (= (acumulado MADERA) 0)
        (= (acumulado PIEDRA) 0)
        (= (acumulado JABALI) 0)
        (= (acumulado OVEJA) 0)
        (= (acumulado VACA) 0)
        (= (acumulado COMIDA) 0)
      ;; Contadores de mendicidad de jugadores
        (= (mendigo J1) 0)
        (= (mendigo J2) 0)
      ;; Contadores de animales de jugadores
        (= (animales J1) 0)
        (= (animales J2) 0)
  	  ;; Familiares
      	(= (familiares-jugador J1) 2)
      	(= (familiares-jugador J2) 2)
      ;; Campos arados
      	(= (arado J1) 0)
      	(= (arado J2) 0)
      ;; Campos sembrados
      	(= (sembrado J1 CEREAL) 0)
      	(= (sembrado J1 HORTALIZA) 0)
      	(= (sembrado J2 CEREAL) 0)
      	(= (sembrado J2 HORTALIZA) 0)
      ;; Recursos a recoger
      	(= (cosechable J1 CEREAL) 0)
      	(= (cosechable J1 HORTALIZA) 0)
      	(= (cosechable J2 CEREAL) 0)
      	(= (cosechable J2 HORTALIZA) 0)
      ;; Maximo numero de animales posible. Depende de los pastos vallados
      	(= (maximo_animales J1) 0)
      	(= (maximo_animales J2) 0)
    ;; Constantes del problema
	    (next-jugador J1 J2)
	    (next-material MADERA ADOBE) (next-material ADOBE PIEDRA)
	    (next-ronda UNO DOS) (next-ronda DOS TRES) (next-ronda TRES CUATRO)
      (next-familiar F1 F2) (next-familiar F2 F3)
      ;; Recursos que se pueden cocinar para obtener comida
        (cocinable HORTALIZA)
        (cocinable OVEJA)
        (cocinable JABALI)
        (cocinable VACA)
      ;; Equivalencia en comida de cada elemento cocinable
        (= (cocinable HORTALIZA) 3)
        (= (cocinable OVEJA) 2)
        (= (cocinable JABALI) 3)
        (= (cocinable VACA) 4)
      ;;; Equivalencia de la comida obtenida al hornear con cada adquisicion
        (= (hornear COCINA) 3)
        (= (hornear HORNO) 5)
      ;; Recursos animales
        (animal JABALI)
        (animal OVEJA)
        (animal VACA)
      ;; Acciones complejas
      ;; Habilitar acciones
        (accion-complex COGER JUNCO)
        (accion-complex COGER CEREAL)
        (accion-complex COGER HORTALIZA)
        (accion-complex COGER COMIDA)
        (accion-complex COGER-ACUM ADOBE)
        (accion-complex COGER-ACUM JUNCO)
        (accion-complex COGER-ACUM MADERA)
        (accion-complex COGER-ACUM PIEDRA)
        (accion-complex COGER-ACUM JABALI)
        (accion-complex COGER-ACUM OVEJA)
        (accion-complex COGER-ACUM VACA)
        (accion-complex COGER-ACUM COMIDA)
        (accion-complex SEMBRAR HORTALIZA)
        (accion-complex SEMBRAR CEREAL)
  )

  (:goal
    (fase-partida FIN)
  )
)
