;;;;;;; Agricola ;;;;;;;

(define (domain AGRICOLA)
  ;; "equality" para poder hacer comparaciones de igualdad con =
  (:requirements :strips :typing :fluents :equality)

  (:types fase-ronda fase-juego numeros jugadores posesiones acciones)

  (:constants
    REPOSICION INICIO JORNADA ROTA_TURNO FIN COSECHA CAMBIO_RONDA - fase-ronda
    RONDAS FIN - fase-juego
    RECOLECCION ALIMENTACION - fase-cosecha
    CERO UNO DOS TRES CUATRO - numeros
    J1 J2 - jugadores
    HORNO COCINA - adquisiciones
    MADERA ADOBE PIEDRA JUNCO CEREAL HORTALIZA COMIDA OVEJA JABALI VACA - posesiones
    COGER COGER-ACUM REFORMAR CONS-HAB AMPLIAR ARAR VALLAR COMPRAR SEMBRAR HORNEAR - acciones
  )

  (:functions
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
    ;; Numero de campos sembrados
    (sembrado ?j - jugadores ?s - posesiones)
    ;; Numero de semillas a recolectar
    (cosechable ?j - jugadores ?s - posesiones)
    ;; Equivalencia en comidas de cada elemento cocinable
    (cocinable ?c - posesiones)
    ;; HORNEAR
    (hornear ?a - adquisiciones)
    ;; Familiares maximos que se pueden tener
    (familiares-max)
  )

  (:predicates
  	;; Ronda actual
  	(ronda-actual ?r - numeros)
    ;; Jugador actual
    (jugador-actual ?nj - jugadores)
    ;; Fase de ronda actual
    (fase-ronda ?r - fase-ronda)
    ;; Fase de juego actual
    (fase-partida ?p - fase-juego)
    ;; Cambio de jugador
    (next-jugador ?j1 ?j2 - jugadores)
    ;; Iteracion de numeros
    (next-numero ?n1 ?n2 - numeros)
    ;; Cambio de material de las habitaciones
    (next-material ?m1 ?m2 - posesiones)
    ;; Material del que estan hechas las habitaciones
    (material_casa ?j - jugadores ?m - posesiones)
    ;; Acciones de coger recursos
    (accion-complex ?a - acciones ?m - posesiones)
    ;; Control de que las acciones solo se hagan una vez
    (accion-realizada ?a - acciones)
    ;; Control de que las acciones complejas solo se hagan una vez
    (accion-realizada-complex ?a - acciones ?m - posesiones)
    ;; Control de cosecha. Determina una fase de la cosecha que se ha completado
    (cosecha ?fc - fase-cosecha ?j - jugadores)
    ;; Determina si se ha recolectado un tipo de sembrado concreto de un jugador
    (cosecha_recolectar-sembrado ?j - jugadores ?s - posesiones)
    ;; Identifica una posesion que se puede cocinar para obtener comida
    (cocinable ?pos - posesiones)
    ;; Identifica una posesion de tipo animal
    (animal ?pos - posesiones)
    ;; Asocia una adquisicion a un jugador
    (adquisicion ?a - adquisiciones ?j - jugadores)

    ;; Familiar considerado en el turno actual
    (familiar_actual ?f - numeros)
    ;; Mayor indice de familiar que tiene un jugador
    (familiar_max-jugador ?j - jugadores ?f - numeros)
    ;; Maximos familiares
    (familiar_max ?fm - numeros)

    (accion-complex-bloqueada ?a - acciones ?p - posesiones ?r - numeros)
  )


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; COSECHA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Recolectar sembrados
  (:action COSECHA_recolectar-sembrado
    :parameters
      (?j - jugadores ?s - posesiones)
    :precondition
      (and
        (fase-ronda COSECHA)
        (accion-complex SEMBRAR ?s)
        ;; No se ha recolectado aun el sembrado
        (not (cosecha_recolectar-sembrado ?j ?s))
      )
    :effect
      (and
        (decrease (cosechable ?j ?s) 1)
        (increase (recursos ?j ?s) 1)
        (cosecha_recolectar-sembrado ?j ?s)

        ;; Sembrado vacio vuelve a ser arado
        ;; rawr - Asume que no hay mas de un sembrado del mismo tipo!
        ;; rawr - (cosechable no referencia a un sembrado concreto, sino a los recursos)
        (when (= (cosechable ?j ?s) 0)
          (and
            (decrease (sembrado ?j ?s) 1)
            (increase (arado ?j) 1)
          )
        )
      )
  )

  ;; Comprueba que todos los sembrados de un jugador han sido recolectados
  (:action COSECHA_recolectar
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; El jugador aun no ha completado la recoleccion
        (not (cosecha RECOLECCION ?j))
        ;; No existe sembrado por cosechar
        (not
          (exists (?s - posesiones)
            (and
              (accion-complex SEMBRAR ?s)
              (> (cosechable ?j ?s) 0)
              (not (cosecha_recolectar-sembrado ?j ?s))
            )
          )
        )
      )
    :effect
      (cosecha RECOLECCION ?j)
  )

  ;; Alimenta familiares
  (:action COSECHA_alimentar
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha ALIMENTACION ?j))
        ;; Recursos suficientes para alimentar a todos los familiares
        (>= (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
      )
    :effect
      (and
        (decrease (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
        (cosecha ALIMENTACION ?j)
      )
  )

  ;; Convierte un cocinable en una unidad de comida si tiene una cocina y necesita comida
  (:action COSECHA_convertir-comida
    :parameters
      (?j - jugadores ?pos - posesiones)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha ALIMENTACION ?j))
        ;; Recursos insuficientes para alimentar a familiares
        (< (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
        ;; Puede convertir algun recurso en comida
        (> (recursos ?j ?pos) 0)
        ;; Tiene cocina
        (adquisicion COCINA ?j)
        (cocinable ?pos)
      )
    :effect
      (and
        ;; Incrementa la comida del jugador tantas unidades como el recurso original pueda
        (increase (recursos ?j COMIDA) (cocinable ?pos))
        (decrease (recursos ?j ?pos) 1)
        (when (animal ?pos) (decrease (animales ?j) 1))
      )
  )

  ;; Mendiga comida si necesita comida y no tiene cocinables
  (:action COSECHA_mendigar-comida
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (fase-ronda COSECHA)
        ;; No se ha completado la alimentacion en la cosecha actual
        (not (cosecha ALIMENTACION ?j))
        ;; Recursos insuficientes para alimentar a familiares
        (< (recursos ?j COMIDA) (* (familiares-jugador ?j) 2))
        ;; No puede convertir ningun recurso en comida (no tiene cocina o no tiene cocinables)
        (or
          (not (adquisicion COCINA ?j))
          (not
            (exists (?pos - posesiones)
              (and
                (cocinable ?pos)
                (> (recursos ?j ?pos) 0)
              )
            )
          )
        )
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
        ;; Todos los jugadores han completado todas las fases de cosecha
        (not
          (exists (?j - jugadores ?fc - fase-cosecha)
            (not (cosecha ?fc ?j))
          )
        )
      )
    :effect
      (and
        (not (fase-ronda COSECHA))
        (fase-ronda CAMBIO_RONDA)
        ;; Elimina predicados auxiliares al final de la cosecha
        (forall (?j - jugadores ?fc - fase-cosecha) (not (cosecha ?fc ?j)))
      )
  )


  ;;;;;;;;;;;;;;;;;;;;;;;;; CONTROL DE RONDA ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Cambia el familiar del jugador actual
  (:action cambia-turno-familiar
    :parameters
      (?j - jugadores ?fa ?fn - numeros)
    :precondition
      (and
        ;; Comprueba que el jugador tiene otro familiar que puede mover
        (jugador-actual ?j)

        ;; Si familiar actual y maximo del jugador no coinciden, entonces se debe cambiar turno de familiar
        (familiar_actual ?fa)
        (not (familiar_max-jugador ?j ?fa))

        (next-numero ?fa ?fn)

        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia de familiar
        (not (familiar_actual ?fa))
        (familiar_actual ?fn)

        (not (fase-ronda ROTA_TURNO))
        (fase-ronda JORNADA)
      )
  )

  ;; Cambia de jugador cuando se han movido todos los del actual
  (:action cambia-turno-jugador
    :parameters
      (?j1 ?j2 - jugadores ?fa - numeros)
    :precondition
      (and
        (next-jugador ?j1 ?j2)
        (jugador-actual ?j1)

        ;; Si familiar actual y maximo del jugador coinciden, entonces se debe cambiar turno de jugador
        (familiar_actual ?fa)
        (familiar_max-jugador ?j1 ?fa)

        ;; Comprueba que no trata de rotar al ultimo jugador
        (not (jugador-actual J2))
        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Cambia el turno del jugador y resetea el familiar iterado al primero
        (not (jugador-actual ?j1))
        (jugador-actual ?j2)

        (not (familiar_actual ?fa))
        (familiar_actual UNO)

        (not (fase-ronda ROTA_TURNO))
        (fase-ronda JORNADA)
      )
  )

  ;; Si todos los jugadores han movido todos sus familiares, la ronda termina
  (:action fin-ronda
    :parameters
      (?fa - numeros)
    :precondition
      (and
        ;; Comprueba que es el ultimo jugador
        (jugador-actual J2)

        ;; Comprueba que se han movido todos los familiares del ultimo jugador
        (familiar_actual ?fa)
        (familiar_max-jugador J2 ?fa)

        (fase-ronda ROTA_TURNO)
      )
    :effect
      (and
        ;; Resetea el jugador y el familiar y finaliza la ronda
        (not (jugador-actual J2))
        (jugador-actual J1)

        (not (familiar_actual ?fa))
        (familiar_actual UNO)

        (not (fase-ronda ROTA_TURNO))
        (fase-ronda FIN)
      )
  )

  ;; Si la ronda ha terminado y no es la última (existe next-numero), se cambia de ronda
  (:action nueva-ronda
  	:parameters
  		(?r1 ?r2 - numeros)
    :precondition
      (and
        (fase-ronda CAMBIO_RONDA)
        (next-numero ?r1 ?r2)
        (ronda-actual ?r1)
        ;; El cambio de ronda en cosecha es distinto
        (not (ronda-actual CUATRO))
      )
    :effect
      (and
        ;; Libera acciones en la ronda
        (accion-complex-bloqueada COGER-ACUM ADOBE ?r2)
        (accion-complex-bloqueada COGER-ACUM OVEJA ?r2)
        (accion-complex-bloqueada COGER-ACUM COMIDA ?r2)
        (not (fase-ronda CAMBIO_RONDA))
        (fase-ronda REPOSICION)
        (not (ronda-actual ?r1))
        (ronda-actual ?r2)
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
      	(forall (?a - acciones) (not (accion-realizada ?a)))
      	(forall (?a - acciones ?p - posesiones) (not (accion-realizada-complex ?a ?p)))
        ;; Control
        (not (fase-ronda INICIO))
        (fase-ronda JORNADA)
      )
  )

  ;; Si se han jugado todas las rondas (numero-ronda -> ULTIMA), la partida termina
  (:action fin-partida
  	:parameters
  		(?c - numeros)
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


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ACCIONES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Recoge una unidad de un recurso no acumulable
  (:action ACCION_Coger-Recurso
    :parameters
      (?j - jugadores ?r - posesiones)
    :precondition
      (and
      	;; Control
        (jugador-actual ?j)
        (fase-ronda JORNADA)
        (accion-complex COGER ?r)
        (not (accion-realizada-complex COGER ?r))
      )
    :effect
      (and
      	;; Accion
        (increase (recursos ?j ?r) 1)
        ;; Control
        (accion-realizada-complex COGER ?r)
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Recoge un recurso de la reserva (acumulable; se lleva todo lo que hay)
  (:action ACCION_Coger-Acumulable
    :parameters
      (?j - jugadores ?r - posesiones ?nr - numeros)
    :precondition
      (and
        (not (exists (?nr - numeros) (accion-complex-bloqueada COGER-ACUM ?r ?nr)))

      	;; Control
        (jugador-actual ?j)
        (fase-ronda JORNADA)
        (accion-complex COGER-ACUM ?r)
        (not (accion-realizada-complex COGER-ACUM ?r))
        ;; La toma de animales requiere de otras comprobaciones
        (not (animal ?r))
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
        (accion-realizada-complex COGER-ACUM ?r)
      )
  )

  ;; Recoge animales de la reserva
  (:action ACCION_Coger-Acumulable_Animal
    :parameters
      (?j - jugadores ?r - posesiones)
    :precondition
      (and
      	;; Control
        (jugador-actual ?j)
      	(accion-complex COGER-ACUM ?r)
        (fase-ronda JORNADA)
        (not (accion-realizada-complex COGER-ACUM ?r))
        ;; Accion
        (animal ?r)
        (> (acumulado ?r) 0)
        ;; El jugador puede alojar al animal
        (> (maximo_animales ?j) (animales ?j))
      )
    :effect
      (and
        ;; Acciones
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
        (accion-realizada-complex COGER-ACUM ?r)
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
      	;; Contol
      	(not (accion-realizada CONS-HAB))
	      (fase-ronda JORNADA)
	      ;; Accion
	      (jugador-actual ?j)
	      (> (huecos ?j) 0)
	      (material_casa ?j ?m)
	      (>= (recursos ?j JUNCO) 2)
	      (>= (recursos ?j ?m) 5)
        ;; No se construyen mas habitaciones que familiares totales se puede tener
        (< (habitaciones ?j) (familiares-max))
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
      	(decrease (recursos ?j JUNCO) 2)
      	(decrease (recursos ?j ?m) 5)
      	(increase (habitaciones ?j) 1)
      	;; Control
      	(accion-realizada CONS-HAB)
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
      	  ;; Control
      	  (not (accion-realizada REFORMAR))
	      (fase-ronda JORNADA)
	      ;; Accion
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
      	(accion-realizada REFORMAR)
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  ;; Ampliar familia con habtaciones para todos los miembros
  (:action ACCION_Ampliar-Familia
  	:parameters
      (?j - jugadores ?fj ?fn - numeros)
    :precondition
      (and
      	;; Control
      	(fase-ronda JORNADA)
      	(not (accion-realizada AMPLIAR))
      	;; Accion
	    (jugador-actual ?j)
      (familiar_max-jugador ?j ?fj)
      ;; No se ha alcanzado el limite de familiares
      (not (familiar_max ?fj))
      (next-numero ?fj ?fn)
	    (< (familiares-jugador ?j) (habitaciones ?j))
	  )
    :effect
      (and
      	;; Accion
      	(increase (familiares-jugador ?j) 1)
        (not (familiar_max-jugador ?j ?fj))
        (familiar_max-jugador ?j ?fn)
      	;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
        (accion-realizada AMPLIAR)
      )
  )

  (:action ACCION_Arar
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	  ;; Control
      	  (not (accion-realizada ARAR))
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
      	(accion-realizada ARAR)
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
      	  (not (accion-realizada VALLAR))
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
	      ;; Acciones
	      (> (huecos ?j) 0)
	      (>= (recursos ?j MADERA) 4)
      )
    :effect
      (and
      	;; Acciones
      	(decrease (huecos ?j) 1)
        ;; Un pasto vallado puede albergar dos animales mas
      	(increase (maximo_animales ?j) 2)
      	(decrease (recursos ?j MADERA) 4)
      	;; Control
      	(accion-realizada VALLAR)
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
      )
  )

  (:action ACCION_Sembrar
  	:parameters
      (?j - jugadores ?s - posesiones)
    :precondition
      (and
      	  ;; Control
	      (fase-ronda JORNADA)
	      (jugador-actual ?j)
	      (accion-complex SEMBRAR ?s)
	      (not (accion-realizada SEMBRAR))
	      ;; Acciones
	      (>= (recursos ?j ?s) 1)
	      (> (arado ?j) 0)
      )
    :effect
      (and
      	;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
        (accion-realizada SEMBRAR)
      	;; Acciones
      	(decrease (recursos ?j ?s) 1)
      	(decrease (arado ?j) 1)
      	(increase (sembrado ?j ?s) 1)
      	(increase (cosechable ?j ?s) 2)
      )
  )

  ;; Compra una adquisicion mayor de tipo horno
  (:action ACCION_Comprar-Horno
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (jugador-actual ?j)
        (fase-ronda JORNADA)
        ;; Ningun jugador ha comprado ya el horno
        (not (exists (?js - jugadores) (adquisicion HORNO ?js)))
        (>= (recursos ?j ADOBE) 3)
        (>= (recursos ?j PIEDRA) 1)
	      (not (accion-realizada COMPRAR))
      )
    :effect
      (and
      	;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
        (accion-realizada COMPRAR)
        ;; Acciones
        (decrease (recursos ?j ADOBE) 3)
        (decrease (recursos ?j PIEDRA) 1)
        (adquisicion HORNO ?j)
      )
  )

  ;; Compra una adquisicion mayor de tipo cocina
  (:action ACCION_Comprar-Cocina
    :parameters
      (?j - jugadores)
    :precondition
      (and
        (jugador-actual ?j)
        (fase-ronda JORNADA)
        ;; Ningun jugador ha comprado ya la cocina
        (not (exists (?js - jugadores) (adquisicion COCINA ?js)))
        (>= (recursos ?j ADOBE) 4)
	      (not (accion-realizada COMPRAR))
      )
    :effect
      (and
      	;; Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
        (accion-realizada COMPRAR)
        ;; Acciones
        (decrease (recursos ?j ADOBE) 4)
        (adquisicion COCINA ?j)
      )
  )

  (:action ACCION_Hornear
    :parameters
      (?j - jugadores ?a - adquisiciones)
    :precondition
      (and
        ;; Control
        (jugador-actual ?j)
        (fase-ronda JORNADA)
        (not (accion-realizada HORNEAR))
        ;; Accion
        (adquisicion ?a ?j)
        (>= (recursos ?j CEREAL) 1)
      )
    :effect
      (and
        ;;Control
        (not (fase-ronda JORNADA))
        (fase-ronda ROTA_TURNO)
        (accion-realizada HORNEAR)
        ;;Accion
        (decrease (recursos ?j CEREAL) 1)
        (increase (recursos ?j COMIDA) (hornear ?a))
      )

  )
)
