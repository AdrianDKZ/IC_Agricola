;; Ampliar familia sin habitaciones disponibles
(:action ampliar-familia2
  	:parameters
      (?j - jugadores)
    :precondition
      (and
      	(ronda JORNADA)
	    (numero-jugador ?j)
	  )
    :effect
      (and
      	(increase (familiares-jugador ?j) 1)
        (not (ronda JORNADA))
        (ronda ROTA_TURNO)
      )
  )