;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types fase-ronda fase-juego contador jugadores)

  (:constants
    INICIO JORNADA ROTA_TURNO FIN - fase-ronda
    RONDAS FIN - fase-juego
    UNO DOS TRES CUATRO - contador
    J1 J2 - jugadores
  )

  (:functions
    ;; Familiar a usar el jugador actual
    (familiar-actual)
    ;; Total de familiares de cada jugador
    (familiares-jugador ?fj - jugadores)
  )

  (:predicates
    ;; Cambio de ronda
  	(next-ronda ?c1 ?c2 - contador)
    ;; Cambio de jugador
    (next-jugador ?j1 ?j2 - jugadores)
    ;; Ronda actual
  	(numero-ronda ?n - contador)
    ;; Jugador actual
    (numero-jugador ?nj - jugadores)
    ;; Fase de ronda actual
    (ronda ?r - fase-ronda)
    ;; Fase de juego actual
    (partida ?p - fase-juego)
  )

  ;; Cambia el familiar del jugador actual
  (:action cambia-turno-familiar
    :parameters
      (?j - jugadores)
    :precondition
      (and
        ;; Comprueba que el jugador tiene otro familiar que puede mover
        (< (familiar-actual) (familiares-jugador ?j))
        (ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia de familiar
        (increase (familiar-actual) 1)
        (not (ronda ROTA_TURNO))
        (ronda JORNADA)
      )
  )

  ;; Cambia de jugador cuando se han movido todos los del actual
  (:action cambia-turno-jugador
    :parameters
      (?j1 ?j2 - jugadores)
    :precondition
      (and
        (next-jugador ?j1 ?j2)
        (numero-jugador ?j1)
        (= (familiar-actual) (familiares-jugador ?j1))
        ;; Comprueba que no trata de rotar al ultimo jugador
        (not (numero-jugador J2))
        (ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia el turno del jugador y resetea el familiar iterado al primero
        (not (numero-jugador ?j1))
        (numero-jugador ?j2)
        (assign (familiar-actual) 1)
        (not (ronda ROTA_TURNO))
        (ronda JORNADA)
      )
  )

  ;; Representa lo que hace un jugador con su familiar en la jornada laboral
  (:action jornada-trabaja
    :precondition
      (ronda JORNADA)
    :effect
      (and
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

  ;; Si todos los jugadores han movido todos sus familiares, la ronda termina
  (:action fin-ronda
    :parameters
      (?j - jugadores)
    :precondition
      (and
        ;; Comprueba que es el ultimo jugador
        (numero-jugador ?j)
        (numero-jugador J2)
        ;; Comprueba que se han movido todos los familiares del ultimo jugador
        (= (familiar-actual) (familiares-jugador ?j))
        (ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Resetea el jugador y el familiar y cambia la ronda
        (not (numero-jugador J2))
        (numero-jugador J1)
        (assign (familiar-actual) 1)
        (not (ronda ROTA_TURNO))
        (ronda FIN)
      )
  )

  ;; Si la ronda ha terminado y no es la última (existe next-ronda), se cambia de ronda
  (:action cambia-ronda
    :parameters
      (?c1 ?c2 - contador)
    :precondition
      (and
        (ronda FIN)
        (next-ronda ?c1 ?c2)
        (numero-ronda ?c1)
      )
    :effect
      (and
        (not (ronda FIN))
        (ronda INICIO)
        (not (numero-ronda ?c1))
        (numero-ronda ?c2)
      )
  )

  ;; Inicio de ronda
  (:action inicio-ronda
    :precondition
      (and
        (ronda INICIO)
      )
    :effect
      (and
        (not (ronda INICIO))
        (ronda JORNADA)
      )
  )

  ;; Si se han jugado todas las rondas (numero-ronda -> ULTIMA), la partida termina
  (:action fin-partida
    :precondition
      (and
        (ronda FIN)
        (numero-ronda CUATRO)
        (partida RONDAS)
      )
    :effect
      (and
        (not (partida RONDAS))
        (partida FIN)
      )
  )
)
