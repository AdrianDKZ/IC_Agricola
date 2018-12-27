;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types fase-ronda fase-juego contador jugadores materiales)

  (:constants
    REPOSICION INICIO JORNADA ROTA_TURNO FIN COSECHA - fase-ronda
    RONDAS FIN - fase-juego
    UNO DOS TRES CUATRO - contador
    J1 J2 - jugadores
    ADOBE JUNCO MADERA PIEDRA JABALI OVEJA VACA CEREAL HORTALIZA COMIDA - posesiones
    MADERA ADOBE PIEDRA - materiales
    ADOBE JUNCO MADERA PIEDRA JABALI OVEJA VACA COMIDA - recursos_acumulables
    JUNCO CEREAL HORTALIZA COMIDA - recursos_noacumulables
  )

  (:functions
    ;; Familiar a usar el jugador actual
    (familiar-actual)

    ;; Total de familiares de cada jugador
    (familiares-jugador ?fj - jugadores)

    ;; Numero de huecos restantes
    (huecos ?j - jugadores)

    ;; Numero de habitaciones del jugador
    (habitaciones ?j - jugadores)

    ;; Contadores para las posesiones del jugador
    (recursos ?j - jugadores ?pos - posesiones)

    ;; Contador asociado a los recursos acumulables
    (acumulado ?r - recursos_acumulables)

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
    ;; Material del que estan hechas las habitaciones
    (material_casa ?j - jugadores ?m - materiales)
    ;; Cambio de material de las habitaciones
    (next-material ?m1 ?m2 - materiales)
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
  ;;(:action jornada-trabaja
    ;;:precondition
      ;;(ronda JORNADA)
    ;;:effect
      ;;(and
        ;;(not (ronda JORNADA))
        ;;(ronda ROTA_TURNO)
      ;;)
  ;;)

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
        (ronda REPOSICION)
        (not (numero-ronda ?c1))
        (numero-ronda ?c2)
      )
  )

  ;; Inicio de ronda
  ;; Actualiza acumulables
  (:action inicio_ronda-actualiza_acumulable
    :precondition
      (and
        (ronda REPOSICION)
      )
    :effect
      (and
        ;; Accion
        (increase (acumulado ADOBE) 1)
        (increase (acumulado JUNCO) 1)
        (increase (acumulado MADERA) 3)
        (increase (acumulado PIEDRA) 1)
        (increase (acumulado JABALI) 1)
        (increase (acumulado OVEJA) 1)
        (increase (acumulado VACA) 1)
        (increase (acumulado COMIDA) 1)
        ;; Control
        (not (ronda REPOSICION))
        (ronda INICIO)
      )
  )

  ;; Fin inicio de ronda
  ;; Acumulables actualizados
  (:action inicio_ronda-fin
    :precondition
      (and
        (ronda INICIO)
      )
    :effect
      (and
        ;; Control
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

  ;; Recoge una unidad de un recurso no acumulable
  (:action accion_coger-noacumulable
    :parameters
      (?j - jugadores ?r - recursos_noacumulables)
    :precondition
      (and
        (ronda JORNADA)
      )
    :effect
      (and
        (increase (recursos ?j ?r) 1)
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

  ;;; Recoge un recurso de la reserva (acumulable; se lleva todo lo que hay)
  (:action accion_coger-acumulable
    :parameters
      (?j - jugadores ?r - recursos_acumulables)
    :precondition
      (and
        (ronda JORNADA)
        (> (acumulado ?r) 0)
      )
    :effect
      (and
        ;; Acciones
        (increase (recursos ?j ?r) (acumulado ?r))
        (assign (acumulado ?r) 0)
        ;; Control
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

  ;; Construye una habitacion
  (:action contruir-habitacion
  	:parameters
      (?j - jugadores ?m - materiales)
    :precondition
      (and
	      (ronda JORNADA)
	      (numero-jugador ?j)
	      (> (huecos ?j) 0)
	      (material_casa ?j ?m)
	      (>= (recursos ?j JUNCO) 2)
	      (>= (recursos ?j ?m) 5)
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
      	(decrease (recursos ?j JUNCO) 2)
      	(decrease (recursos ?j ?m) 5)
      	(increase (habitaciones ?j) 1)
      	;; Control
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

   ;; Construye una habitacion
  (:action reformar-casa
  	:parameters
      (?j - jugadores ?m1 ?m2 - materiales)
    :precondition
      (and
	      (ronda JORNADA)
	      (numero-jugador ?j)
	      (material_casa ?j ?m1)
	      (next-material ?m1 ?m2)
	      (>= (recursos ?j JUNCO) 1)
	      (>= (recursos ?j ?m2) (habitaciones ?j))
      )
    :effect
      (and
      	;; Acciones
      	(not (material_casa ?j ?m1))
      	(material_casa ?j ?m2)
      	(decrease (recursos ?j JUNCO) 1)
      	(decrease (recursos ?j ?m2) (habitaciones ?j))
      	;; Control
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

  ;; Ampliar familia con habtaciones para todos los miembros
  (:action ampliar-familia
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	(ronda JORNADA)
	    (numero-jugador ?j)
	    (< (familiares-jugador ?j) (habitaciones ?j))
	  )
    :effect
      (and
      	(increase (familiares-jugador ?j) 1)
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )


)
