(define (problem desarrollo) (:domain AGRICOLA)
  (:objects
  )
  (:init
    ;;;;;;;;;;;;;;;;;; ELEMENTOS A MODIFICAR PARA LAS PRUEBAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Maximos
        ;; Ronda - MAXIMO DE OCHO
          (ronda-final CUATRO)
        ;; Familiares - MAXIMO DE OCHO
          (familiar_max TRES)
          (= (familiares-max) 3)
      ;; Familiares iniciales
        (= (familiares-jugador J1) 2)
        (= (familiares-jugador J2) 2)
        (familiar_max-jugador J1 DOS)
        (familiar_max-jugador J2 DOS)
        ;;;; DEPENDIENTE DE LOS VALORES ANTERIORES ;;;;
        ;; Mismas habitaciones que familiares
          (= (habitaciones J1) 2)
          (= (habitaciones J2) 2)
        ;; Huecos = 15 - numero de habitaciones
          (= (huecos J1) 13)
          (= (huecos J2) 13)

  ;;;;;;;;;;;;;;;;;;;;;;;;; ELEMENTOS QUE NO SE MODIFICAN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;; NECESARIOS PARA LA INICIALIZACION ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Ronda y mecanismos de iteracion iniciales
      (ronda-actual UNO)
      (jugador-actual J1)
      (familiar_actual UNO)
      (fase-ronda REPOSICION)
      (fase-partida RONDAS)
    ;; Elementos iniciales
      ;;Materiales iniciales de la casa
        (material_casa J1 MADERA)
        (material_casa J2 MADERA)
      ;; Recursos que se obtienen al sembrar una semilla de un tipo
        (= (sembrable HORTALIZA) 2)
        (= (sembrable CEREAL) 3)
      ;; Equivalencia en comida de cada elemento cocinable
        (= (cocinable HORTALIZA) 3)
        (= (cocinable OVEJA) 2)
        (= (cocinable JABALI) 3)
        (= (cocinable VACA) 4)
      ;;; Equivalencia de la comida obtenida al hornear con cada adquisicion
        (= (hornear COCINA) 3)
        (= (hornear HORNO) 5)
    ;; Inicializacion de las funciones
      ;; Contadores de métrica
        (= (total-cost) 0)
        (= (penalty J1) 0)
        (= (penalty J2) 0)
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
      ;; Contadores de animales de jugadores
        (= (animales J1) 0)
        (= (animales J2) 0)
      ;; Campos arados
      	(= (arado J1) 0)
      	(= (arado J2) 0)
      ;; Maximo numero de animales posible. Depende de los pastos vallados
      	(= (maximo_animales J1) 0)
      	(= (maximo_animales J2) 0)
    ;; Constantes del problema
	    (next-jugador J1 J2)
	    (next-material MADERA ADOBE) (next-material ADOBE PIEDRA)
      (next-numero UNO DOS) (next-numero DOS TRES) (next-numero TRES CUATRO) (next-numero CUATRO CINCO)
      (next-numero CINCO SEIS) (next-numero SEIS SIETE) (next-numero SIETE OCHO)
    ;; Determinacion de los elementos
      ;; Recursos que se pueden cocinar para obtener comida
        (cocinable HORTALIZA)
        (cocinable OVEJA)
        (cocinable JABALI)
        (cocinable VACA)
      ;; Recursos animales
        (animal JABALI)
        (animal OVEJA)
        (animal VACA)
    ;; Acciones complejas
      (accion-complex COGER JUNCO)
      (accion-complex COGER CEREAL)
      (accion-complex COGER HORTALIZA)
      (accion-complex COGER COMIDA)
      (accion-complex COGER-ACUM ADOBE)
      (accion-complex COGER-ACUM JUNCO)
      (accion-complex COGER-ACUM MADERA)
      (accion-complex COGER-ACUM PIEDRA)
      (accion-complex COGER-ACUM JABALI)
      (accion-complex COGER-ACUM OVEJA)
      (accion-complex COGER-ACUM VACA)
      (accion-complex COGER-ACUM COMIDA)
      (accion-complex SEMBRAR HORTALIZA)
      (accion-complex SEMBRAR CEREAL)
  )

  (:goal
    (fase-partida FIN)
  )
  (:metric minimize (total-cost))
)
