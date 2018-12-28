(define (problem desarrollo) (:domain AGRICOLA)
  (:objects
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
      ;; Pastos vallados
      	(= (vallado J1) 0)
      	(= (vallado J2) 0)
    ;; Constantes del problema
	    (next-jugador J1 J2)
	    (next-material MADERA ADOBE) (next-material ADOBE PIEDRA)
	    (next-ronda UNO DOS) (next-ronda DOS TRES) (next-ronda TRES CUATRO)
      ;; Recursos comestibles
        (comestible COMIDA)
        (comestible CEREAL)
        (comestible HORTALIZA)
      ;; Recursos animales
        (animal JABALI)
        (animal OVEJA)
        (animal VACA)
  )

  (:goal
    (fase-partida FIN)
  )
)
