(define (problem problem)
  (:domain AGRICOLA)
  (:objects
    J1 J2 - jugadores
  )

  (:init
    ;; Jugadores y sus familiares asociados. Inicializa ronda
    (numero-jugador J1)
    (= (familiares-jugador J1) 2)
    (= (familiares-jugador J2) 3)
    (numero-ronda UNO)
    (= (familiar-actual) 1)

    ;; Ronda y mecanismos de iteracion
    (ronda INICIO)
    (partida RONDAS)
    (next-ronda UNO DOS) (next-ronda DOS TRES) (next-ronda TRES CUATRO)
    (next-jugador J1 J2)

  )
  (:goal
    (partida FIN)
  )
)
