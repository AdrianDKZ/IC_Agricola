(define (problem problem)
  (:domain AGRICOLA)
  (:objects
    J1 J2 - jugadores
  )

  (:init
    ;; Ronda y mecanismos de iteracion
      (numero-ronda UNO)
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
    (next-ronda UNO DOS) (next-ronda DOS TRES) (next-ronda TRES CUATRO)
    (next-jugador J1 J2)
    (next-material MADERA ADOBE) (next-material ADOBE PIEDRA)
    ;; Jugadores y sus familiares asociados. Inicializa ronda
    (= (familiares-jugador J1) 2)
    (= (familiares-jugador J2) 3)
  )

  (:goal
    (partida FIN)
  )
)
