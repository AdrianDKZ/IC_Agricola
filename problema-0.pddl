(define (problem problem-0)
  (:domain AGRICOLA)
  ;; rawr
  (:objects
    J1 J2 - jugadores
  )

  (:init
    ;; Ronda y mecanismos de iteracion
      (= (ronda_actual) 1)
      (numero-jugador J1)
      (ronda INICIO)
      (partida RONDAS)
      (= (familiar-actual) 1)
    ;; Elementos iniciales
      (= (huecos J1) 13)
      (= (huecos J2) 13)
      ;; Habitaciones
        (= (habitaciones J1) 2)
        (= (habitaciones J2) 2)
        (material_casa J1 MADERA)
        (material_casa J2 MADERA)
    ;; Constantes del problema
    (next-jugador J1 J2)
    (next-material MADERA ADOBE)
    ;; Jugadores y sus familiares asociados. Inicializa ronda
    (= (familiares-jugador J1) 2)
    (= (familiares-jugador J2) 3)
    ;; Recursos de los jugadores (inicializacion)
    (= (recursos J1 ADOBE) 0)
    (= (recursos J1 MADERA) 0)
    (= (recursos J1 JABALI) 0)
    (= (recursos J1 COMIDA) 0)
    (= (recursos J2 ADOBE) 0)
    (= (recursos J2 MADERA) 0)
    (= (recursos J2 JABALI) 0)
    (= (recursos J2 COMIDA) 0)

    (= (ultima_ronda-accion COGER_ACUM ADOBE) 0)
    (= (ultima_ronda-accion COGER_ACUM MADERA) 0)
    (= (ultima_ronda-accion COGER_ACUM JABALI) 0)
    ;;(= (ultima_ronda-accion COGER_ACUM COMIDA) 0)
    (= (ultima_ronda-accion COGER_NOACUM CEREAL) 0)
    (= (ultima_ronda-accion COGER_NOACUM COMIDA) 0)
  )

  (:goal
    (partida FIN)
  )
)
