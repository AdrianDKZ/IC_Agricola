(define (problem asdfg) (:domain AGRICOLA)
  (:objects
  	J1 J2 - jugadores
  )
  (:init
    ;; Ronda y mecanismos de iteracion
      (ronda-actual UNO)
      (jugador-actual J1)
      (fase-ronda REPOSICION)
      (fase-partida RONDAS)
      (= (familiar-actual) 1)
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
	  ;; Familiares
    	(= (familiares-jugador J1) 2)
    	(= (familiares-jugador J2) 2)
    ;; Constantes del problema
    (next-jugador J1 J2)
    (next-material MADERA ADOBE) (next-material ADOBE PIEDRA)
    (next-ronda UNO DOS) (next-ronda DOS TRES) (next-ronda TRES CUATRO)
  )

  (:goal
    (fase-partida FIN)
  )
)
