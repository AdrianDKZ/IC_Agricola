;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types boolean fase-ronda fase-juego num-ronda jugadores posesiones acciones)

  (:constants
    REPOSICION INICIO JORNADA ROTA_TURNO FIN COSECHA CAMBIO_RONDA - fase-ronda
    RONDAS FIN - fase-juego
    RECOLECTAR ALIMENTAR PROCREAR - fase-cosecha
    CERO UNO DOS TRES CUATRO - num-ronda
    J1 J2 - jugadores
    MADERA ADOBE PIEDRA JUNCO CEREAL HORTALIZA COMIDA OVEJA JABALI VACA - posesiones
    COGER COGER-ACUM REFORMAR CONS-HAB AMPLIAR ARAR VALLAR - acciones
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
    (acumulado ?r - posesiones)
    ;; Campos arados
    (arado ?j - jugadores)
    ;; Numero maximo de animales que puede tener un jugador. Depende de los pastos vallados
    (maximo_animales ?j - jugadores)
    ;; Veces que un jugador ha mendigado
    (mendigo ?j - jugadores)
    ;; Animales que tiene un jugador (de cualquier tipo)
    (animales ?j - jugadores)
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
    ;; Acciones de coger recursos
    (accion-coger ?a - acciones ?m - posesiones)
    ;; Resto de acciones sin tipo requerido
    (accion ?a - acciones)
    ;; Control de cosecha. Determina si se han alimentado a los familiares de un jugador en cosecha
    (cosecha_alimentar ?j - jugadores)
    ;; Identifica una posesion que se puede utilizar para alimentar
    (comestible ?pos - posesiones)
    ;; Identifica una posesion de tipo animal
    (animal ?pos - posesiones)
  )

  ;; Alimenta familiares
  (:action COSECHA_alimentar
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha_alimentar ?j))
        ;; Recursos suficientes para alimentar a todos los familiares
        (>= (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
      )
    :effect
      (and
        (cosecha_alimentar ?j)
        (decrease (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
      )
  )

  ;; Convierte un comestible en una unidad de comida
  (:action COSECHA_convertir-comida
    :parameters
      (?j - jugadores ?pos - posesiones)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha_alimentar ?j))
        ;; Recursos insuficientes para alimentar a familiares
        (< (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
        ;; Puede convertir algun recurso en comida
        (> (recursos ?j ?pos) 0)
        (comestible ?pos)
      )
    :effect
      (and
        ;; Incrementa la comida del jugador
        (increase (recursos ?j COMIDA) 1)
        (decrease (recursos ?j ?pos) 1)
      )
  )

  ;; Mendiga comida si no tiene comestibles
  (:action COSECHA_mendigar-comida
    :parameters
      (?j - jugadores ?pos - posesiones)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha_alimentar ?j))
        ;; Recursos insuficientes para alimentar a familiares
        (< (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
        ;; No puede convertir ningun recurso en comida
        (not (> (recursos ?j ?pos) 0))
        (comestible ?pos)
      )
    :effect
      (and
        ;; Jugador mendiga tantas unidades de comida como le sean necesarias
        (increase (recursos ?j COMIDA) (- (* (familiares-jugador ?j) 2) (recursos ?j COMIDA)))
        (increase (mendigo ?j) (- (* (familiares-jugador ?j) 2) (recursos ?j COMIDA)))
      )
  )

  ;; Fin de la cosecha
  (:action fin-cosecha
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; Todos los jugadores han recolectado sus sembrados en la cosecha
        ;; rawr - (forall (?j - jugadores) (cosecha ?j RECOLECTAR ?nr))
        ;; Todos los jugadores han alimentado a sus familiares en la cosecha
        (forall (?j - jugadores) (cosecha_alimentar ?j))
      )
    :effect
      (and
        (not (fase-ronda COSECHA))
        (fase-ronda CAMBIO_RONDA)
        ;; Elimina predicados auxiliares al final de la cosecha
        (forall (?j - jugadores) (not (cosecha_alimentar ?j)))
      )
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

  ;; Si todos los jugadores han movido todos sus familiares, la ronda termina
  (:action fin-ronda
    :precondition
      (and
        ;; Comprueba que es el ultimo jugador
        (jugador-actual J2)
        ;; Comprueba que se han movido todos los familiares del ultimo jugador
        (= (familiar-actual) (familiares-jugador J2))
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
  (:action nueva-ronda
  	:parameters
  		(?c1 ?c2 - num-ronda)
    :precondition
      (and
        (fase-ronda CAMBIO_RONDA)
        (next-ronda ?c1 ?c2)
        (ronda-actual ?c1)
        ;; El cambio de ronda en cosecha es distinto
        (not (ronda-actual CUATRO))
      )
    :effect
      (and
        (not (fase-ronda CAMBIO_RONDA))
        (fase-ronda REPOSICION)
        (not (ronda-actual ?c1))
        (ronda-actual ?c2)
      )
  )

  ;; Cambio de ronda con COSECHA
  (:action cambia-ronda_cosecha
    :precondition
      (and
        (fase-ronda FIN)
        (ronda-actual CUATRO)
      )
    :effect
      (and
        (not (fase-ronda FIN))
        (fase-ronda COSECHA)
      )
  )

  ;; Pasa a fase de cambio de ronda
  (:action cambia-ronda
    :precondition
      (and
        (fase-ronda FIN)
        (not (ronda-actual CUATRO))
      )
    :effect
      (and
        (not (fase-ronda FIN))
        (fase-ronda CAMBIO_RONDA)
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
      	;; Habilitar acciones
	      	(accion-coger COGER JUNCO)
		    (accion-coger COGER CEREAL)
		    (accion-coger COGER HORTALIZA)
		    (accion-coger COGER COMIDA)
		    (accion-coger COGER-ACUM ADOBE)
		    (accion-coger COGER-ACUM JUNCO)
		    (accion-coger COGER-ACUM MADERA)
		    (accion-coger COGER-ACUM PIEDRA)
		    (accion-coger COGER-ACUM JABALI)
		    (accion-coger COGER-ACUM OVEJA)
		    (accion-coger COGER-ACUM VACA)
		    (accion-coger COGER-ACUM COMIDA)
		    (accion AMPLIAR)
		    (accion REFORMAR)
		    (accion CONS-HAB)
		    (accion ARAR)
		    (accion VALLAR)
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
        (fase-ronda CAMBIO_RONDA)
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
      (?j - jugadores ?r - posesiones)
    :precondition
      (and
        (fase-ronda JORNADA)
        (accion-coger COGER ?r)
      )
    :effect
      (and
        (increase (recursos ?j ?r) 1)
        (not (accion-coger COGER ?r))
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Recoge un recurso de la reserva (acumulable; se lleva todo lo que hay)
  (:action ACCION_Coger-Acumulable
    :parameters
      (?j - jugadores ?r - posesiones)
    :precondition
      (and
        (fase-ronda JORNADA)
        ;; La toma de animales requiere de otras comprobaciones
        (not (animal ?r))
        (accion-coger COGER-ACUM ?r)
        (> (acumulado ?r) 0)
      )
    :effect
      (and
        ;; Acciones
        (not (accion-coger COGER-ACUM ?r))
        (increase (recursos ?j ?r) (acumulado ?r))
        (assign (acumulado ?r) 0)
        ;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Recoge animales de la reserva
  (:action ACCION_Coger-Acumulable_Animal
    :parameters
      (?j - jugadores ?r - posesiones)
    :precondition
      (and
        (fase-ronda JORNADA)
        (animal ?r)
        (accion-coger COGER-ACUM ?r)
        (> (acumulado ?r) 0)
        ;; El jugador puede alojar al animal
        (> (maximo_animales ?j) (animales ?j))
      )
    :effect
      (and
        ;; Acciones
        (not (accion-coger COGER-ACUM ?r))
        (increase (recursos ?j ?r) (acumulado ?r))
        (increase (animales ?j) (acumulado ?r))
        ;; Se prescinden de los animales que no caben
        (when
          ;; Mas animales de los que permite tener el vallado
          (> (animales ?j) (maximo_animales ?j))
            (and
              ;; Animales sobrantes no se consideran
              ;; rawr - si se tiene un hogar, se cocinan!!
              (decrease (recursos ?j ?r) (- (animales ?j) (maximo_animales ?j)))
              (assign (animales ?j) (maximo_animales ?j))
            )
        )
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
      	  (accion CONS-HAB)
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
      	(not (accion CONS-HAB))
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
      	  (accion REFORMAR)
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
      	(not (accion REFORMAR))
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
      	(accion AMPLIAR)
      	(fase-ronda JORNADA)
	    (jugador-actual ?j)
	    (< (familiares-jugador ?j) (habitaciones ?j))
	  )
    :effect
      (and
      	(increase (familiares-jugador ?j) 1)
      	(not (accion AMPLIAR))
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  (:action ACCION_Arar
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	  ;; Control
      	  (accion ARAR)
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
	      ;; Acciones
	      (> (huecos ?j) 0)
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
      	(increase (arado ?j) 1)
      	;; Control
      	(not (accion ARAR))
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  (:action ACCION_Vallar
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	  ;; Control
      	  (accion VALLAR)
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
	      ;; Acciones
	      (> (huecos ?j) 0)
	      (> (recursos ?j MADERA) 4)
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
        ;; Un pasto vallado puede albergar dos animales mas
      	(increase (maximo_animales ?j) 2)
      	(decrease (recursos ?j MADERA) 4)
      	;; Control
      	(not (accion VALLAR))
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )
)
