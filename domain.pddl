;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types fase-ronda fase-juego num-ronda jugadores posesiones)

  (:constants
    REPOSICION INICIO JORNADA ROTA_TURNO FIN COSECHA - fase-ronda
    RONDAS FIN - fase-juego
    UNO DOS TRES CUATRO - num-ronda
    J1 J2 - jugadores
    MADERA ADOBE PIEDRA JUNCO CEREAL HORTALIZA COMIDA OVEJA JABALI VACA - posesiones
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
  	;; Ronda actual
  	(ronda-actual ?r - num-ronda)
    ;; Jugador actual
    (jugador-actual ?nj - jugadores)
    ;; Fase de ronda actual
    (fase-ronda ?r - fase-ronda)
    ;; Fase de juego actual
    (fase-partida ?p - fase-juego)
    ;; Cambio de jugador
    (next-jugador ?j1 ?j2 - jugadores)
    ;; Cambio de ronda
    (next-ronda ?r1 ?r2 - num-ronda)
    ;; Cambio de material de las habitaciones
    (next-material ?m1 ?m2 - posesiones)
    ;; Material del que estan hechas las habitaciones
    (material_casa ?j - jugadores ?m - posesiones)
  )

  ;; Cambia el familiar del jugador actual
  (:action cambia-turno-familiar
    :parameters
      (?j - jugadores)
    :precondition
      (and
        ;; Comprueba que el jugador tiene otro familiar que puede mover
        (< (familiar-actual) (familiares-jugador ?j))
        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia de familiar
        (increase (familiar-actual) 1)
        (not (fase-ronda ROTA_TURNO))
        (fase-ronda JORNADA)
      )
  )

  ;; Cambia de jugador cuando se han movido todos los del actual
  (:action cambia-turno-jugador
    :parameters
      (?j1 ?j2 - jugadores)
    :precondition
      (and
        (next-jugador ?j1 ?j2)
        (jugador-actual ?j1)
        (= (familiar-actual) (familiares-jugador ?j1))
        ;; Comprueba que no trata de rotar al ultimo jugador
        (not (jugador-actual J2))
        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia el turno del jugador y resetea el familiar iterado al primero
        (not (jugador-actual ?j1))
        (jugador-actual ?j2)
        (assign (familiar-actual) 1)
        (not (fase-ronda ROTA_TURNO))
        (fase-ronda JORNADA)
      )
  )

  ;;    ;; Representa lo que hace un jugador con su familiar en la jornada laboral
  ;;    (:action jornada-trabaja
  ;;      :precondition
  ;;        (fase-ronda JORNADA)
  ;;      :effect
  ;;        (and
  ;;          (not (fase-ronda JORNADA))
  ;;          (fase-ronda ROTA_TURNO)
  ;;        )
  ;;    )

  ;; Si todos los jugadores han movido todos sus familiares, la ronda termina
  (:action fin-ronda
    :parameters
      (?j - jugadores)
    :precondition
      (and
        ;; Comprueba que es el ultimo jugador
        (jugador-actual ?j)
        (jugador-actual J2)
        ;; Comprueba que se han movido todos los familiares del ultimo jugador
        (= (familiar-actual) (familiares-jugador ?j))
        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Resetea el jugador y el familiar y cambia la ronda
        (not (jugador-actual J2))
        (jugador-actual J1)
        (assign (familiar-actual) 1)
        (not (fase-ronda ROTA_TURNO))
        (fase-ronda FIN)
      )
  )

  ;; Si la ronda ha terminado y no es la última (existe next-ronda), se cambia de ronda
  (:action cambia-ronda
  	:parameters
  		(?c1 ?c2 - num-ronda)
    :precondition
      (and
        (fase-ronda FIN)
        (next-ronda ?c1 ?c2)
        (ronda-actual ?c1)
      )
    :effect
      (and
        (not (fase-ronda FIN))
        (fase-ronda INICIO)
        (not (ronda-actual ?c1))
        (ronda-actual ?c2)
      )
  )

  ; Inicio de ronda
  ;; Actualiza acumulables
  (:action inicio_ronda-actualiza_acumulable
    :precondition
      (and
        (fase-ronda REPOSICION)
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
        (not (fase-ronda REPOSICION))
        (fase-ronda INICIO)
      )
  )

  ;; Fin inicio de ronda
  ;; Acumulables actualizados
  (:action inicio_ronda-fin
    :precondition
      (and
        (fase-ronda INICIO)
      )
    :effect
      (and
        ;; Control
        (not (fase-ronda INICIO))
        (fase-ronda JORNADA)
      )
  )

  ;; Si se han jugado todas las rondas (numero-ronda -> ULTIMA), la partida termina
  (:action fin-partida
  	:parameters
  		(?c - num-ronda)
    :precondition
      (and
        (fase-ronda FIN)
        (ronda-actual CUATRO)
        (fase-partida RONDAS)
      )
    :effect
      (and
        (not (fase-partida RONDAS))
        (fase-partida FIN)
      )
  )

  ;; Recoge una unidad de un recurso no acumulable
  (:action ACCION_Coger-Recurso
    :parameters
      (?j - jugadores ?r - recursos_noacumulables)
    :precondition
      (and
        (fase-ronda JORNADA)
      )
    :effect
      (and
        (increase (recursos ?j ?r) 1)
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Recoge un recurso de la reserva (acumulable; se lleva todo lo que hay)
  (:action ACCION_Coger-Acumulable
    :parameters
      (?j - jugadores ?r - recursos_acumulables)
    :precondition
      (and
        (fase-ronda JORNADA)
        (> (acumulado ?r) 0)
      )
    :effect
      (and
        ;; Acciones
        (increase (recursos ?j ?r) (acumulado ?r))
        (assign (acumulado ?r) 0)
        ;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Construye una habitacion
  (:action ACCION_Construir-Habitacion
  	:parameters
      (?j - jugadores ?m - posesiones)
    :precondition
      (and
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
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
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

   ;; Construye una habitacion
  (:action ACCION_Reformar-Casa
  	:parameters
      (?j - jugadores ?m1 ?m2 - posesiones)
    :precondition
      (and
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
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
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Ampliar familia con habtaciones para todos los miembros
  (:action ACCION_Ampliar-Familia
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	(fase-ronda JORNADA)
	    (jugador-actual ?j)
	    (< (familiares-jugador ?j) (habitaciones ?j))
	  )
    :effect
      (and
      	(increase (familiares-jugador ?j) 1)
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )
)
