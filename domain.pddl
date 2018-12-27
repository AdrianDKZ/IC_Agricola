;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types fase-ronda fase-juego contador jugadores materiales)

  (:constants
    INICIO JORNADA ROTA_TURNO FIN_RONDA - fase-ronda
    RONDAS FIN - fase-juego
    J1 J2 - jugadores

    MADERA ADOBE JABALI CEREAL COMIDA - posesiones
    MADERA ADOBE - materiales
    MADERA ADOBE JABALI - recursos_acumulables
    CEREAL COMIDA - recursos_noacumulables

    COGER_ACUM COGER_NOACUM CONSTRUIR REFORMAR - tipo_accion
    MADERA ADOBE JABALI COMIDA CEREAL - atributo_accion
  )

  (:functions
    ;; Contador de ronda
    (ronda_actual)

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

    ;; Ultima ronda en que se utilizo la accion (para saber si esta disponible en la ronda actual)
    (ultima_ronda-accion ?t - tipo_accion ?at - atributo_accion)

  )

  (:predicates

    ;; Cambio de jugador
    (next-jugador ?j1 ?j2 - jugadores)

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
        (ronda FIN_RONDA)
      )
  )

  ;; Si la ronda ha terminado y no es la última (existe next-ronda), se cambia de ronda
  (:action cambia-ronda
    :precondition
      (and
        (ronda FIN_RONDA)
        (not (= (ronda_actual) 4))
      )
    :effect
      (and
        (not (ronda FIN_RONDA))
        (ronda INICIO)
        (increase (ronda_actual) 1)
      )
  )

  ;; Fin de inicio de ronda
  ;; No es necesario actualizar los recursos acumulables. Su valor se infiere por la ronda
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
        (ronda FIN_RONDA)
        (= (ronda_actual) 4)
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
        (< (ultima_ronda-accion COGER_NOACUM ?r) (ronda_actual))
        (numero-jugador ?j)
        (ronda JORNADA)
      )
    :effect
      (and
        (assign (ultima_ronda-accion COGER_NOACUM ?r) (ronda_actual))
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
        (< (ultima_ronda-accion COGER_ACUM ?r) (ronda_actual))
        (numero-jugador ?j)
        (ronda JORNADA)
      )
    :effect
      (and
        (assign (ultima_ronda-accion COGER_ACUM ?r) (ronda_actual))
        ;; Asume que hay tantos recursos acumulados como el numero de ronda actual determine
        (increase (recursos ?j ?r) (ronda_actual))
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
        ;; Solo ejecuta accion si esta disponible
        (< (ultima_ronda-accion CONSTRUIR ?m) (ronda_actual))
	      (ronda JORNADA)
	      (numero-jugador ?j)
	      (> (huecos ?j) 0)
	      (material_casa ?j ?m)
	      (>= (recursos ?j ?m) 5)
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
      	(decrease (recursos ?j ?m) 5)
      	(increase (habitaciones ?j) 1)
      	;; Control
        (assign (ultima_ronda-accion CONSTRUIR ?m) (ronda_actual))
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )

   ;; Mejora la casa
  (:action reformar-casa
  	:parameters
      (?j - jugadores ?m1 ?m2 - materiales)
    :precondition
      (and
	      (ronda JORNADA)
	      (numero-jugador ?j)
	      (material_casa ?j ?m1)
	      (next-material ?m1 ?m2)
	      (>= (recursos ?j ?m2) (habitaciones ?j))
      )
    :effect
      (and
      	;; Acciones
      	(not (material_casa ?j ?m1))
      	(material_casa ?j ?m2)
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
