;; ========================================================
;;                   1-define-admin-Keyset & Module
;; ========================================================
(define-keyset 'adminEmpresasAlfonz-keyset (read-keyset "adminEmpresasAlfonz-keyset"))
(module EmpresasBlockchainAlfonz 'adminEmpresasAlfonz-keyset
;; ========================================================
;;                   2-define-schemas-and-table
;; ========================================================
;;EL registro Usuarios son los distintos centros de Distribucion (ciudades)
;; En este ejercicio Usaremos una red para monitorear el volumen de producto
;; Para la empresa COCA_COLA. operando en Mx.
  (defschema Estados-schema
    Volumen:decimal
    keyset:keyset
    productoExportado:string
    )

  (deftable Estados-table:{Estados-schema})

;; --------------------------------------------------------
;;                        3.1-create-account
;; --------------------------------------------------------

  (defun create-account (idEstado Volumen keyset productoExportado)
    (enforce-keyset 'adminEmpresasAlfonz-keyset)
    (enforce (>= Volumen 0.0) "El volumen a mover debe ser positivo")
    (insert Estados-table idEstado
            { "Volumen": Volumen,
              "keyset": keyset,
              "productoExportado": productoExportado
              }))
;; --------------------------------------------------------
;;                        3.2-VolumenActual
;; --------------------------------------------------------
  (defun VolumenActual (idEstado)
    (with-read Estados-table idEstado
      { "Volumen":= Volumen, "keyset":= keyset, "productoExportado":=productoExportado }
      (enforce-one "Access denied"
        [(enforce-keyset keyset)
         (enforce-keyset 'adminEmpresasAlfonz-keyset)])

      (format "El volumen del estado {} es {} de {}"
      [idEstado Volumen productoExportado])
      ))

;; ========================================================
 ;;                         3.3-change-productoExportado
;; ========================================================

  ;; define a function change-nickname that takes parameters id and new-name
  (defun change-productoExportado (idEstado productoExportado )
    ;; enforce user authorization to the id provided
    (with-read Estados-table idEstado
    { "Volumen":= Volumen, "keyset":= keyset }
      ;; enforce user authorization to the provided id
       [(enforce-keyset keyset)
         (enforce-keyset 'adminEmpresasAlfonz-keyset)]
    ;; update the users nickname to the new-name using the given id
    (update Estados-table idEstado { "productoExportado": productoExportado })
    ;; return a message to the user formatted as "Updated name for user [id] to [name]"
    (format "Cambio de producto Exportado {} a nuevo producto Exportado {}"
      [idEstado productoExportado])))


;; ========================================================
;;                          3.4- Rotacion de Keys
;; ========================================================

 ;; define a function rotate-keyset that takes the parameters id and new-keyset
    (defun rotate-keyset (idEstado new-keyset)
(with-read Estados-table idEstado
    { "Volumen":= Volumen, "keyset":= keyset }
      ;; enforce user authorization to the provided id
       [(enforce-keyset keyset)
         (enforce-keyset 'adminEmpresasAlfonz-keyset)]
      ;; update the keyset to the new-keyset for the id in the users table
      (update Estados-table idEstado { "keyset": new-keyset})
      ;; return a message describing the update in the format "Updated keyset for user [id]"
      (format "Updated keyset for user {}"
        [idEstado])
    )
)

;; --------------------------------------------------------
;;                          3.5-pay
;; --------------------------------------------------------

  (defun EnviarDesdeHaciaProducto (EstadoEmisor EstadoReceptor VolumenAEnviar)
    (with-read Estados-table EstadoEmisor { "Volumen":= VolumenEstadoEmisor, "keyset":= keyset, "productoExportado":= productoExportado }
      (enforce-keyset keyset)
      (with-read Estados-table EstadoReceptor { "Volumen":= VolumenEstadoReceptor}
        (enforce (> VolumenAEnviar 0.0) "Negative Transaction Amount")
        (enforce (>= VolumenEstadoEmisor VolumenAEnviar) "Volumen Insuficiente")
        (update Estados-table EstadoEmisor
                { "Volumen": (- VolumenEstadoEmisor VolumenAEnviar) })
        (update Estados-table EstadoReceptor
                { "Volumen": (+ VolumenEstadoReceptor VolumenAEnviar) })
        (format "{} exporto hacia {} el volumen de {}" [EstadoEmisor EstadoReceptor VolumenAEnviar]))))
    )
;; --------------------------------------------------------

;; ========================================================
;;                        4-create-table
;; ========================================================
(create-table Estados-table)

;; ========================================================
;;                       5-create-accounts
;; ========================================================

(create-account "Monterrey" 6000.0   (read-keyset "Monterrey-keyset") "Producto1")
(create-account "Guadalajara" 3500.0  (read-keyset "Guadalajara-keyset") "Producto2")
(create-account "Ciudad de Mexico" 7000.0  (read-keyset "Ciudad de Mexico-keyset") "Producto3")
(create-account "Sonora" 2380.0   (read-keyset "Monterrey-keyset") "Producto4")
(create-account "Baja California Norte" 4720.0  (read-keyset "Guadalajara-keyset") "Producto5")
(create-account "Guerrero" 5350.0  (read-keyset "Ciudad de Mexico-keyset") "Producto6")

;; ========================================================
;;                        6-make-payment
;; ========================================================

(EnviarDesdeHaciaProducto "Ciudad de Mexico" "Guadalajara" 1500.0)

(format "Perfecto: {}" [(VolumenActual "Monterrey")])
(format "Perfecto: {}" [(VolumenActual "Guadalajara")])
(format "Perfecto: {}" [(VolumenActual "Ciudad de Mexico")])

;; ========================================================
;;                        7-Usar Select y mostrar los datos
;; Errores al correr Select o Read
;; Cuando es leer o modificar, accede a los datos, pero no para subirlos, ocupas
;; un servidor local de Pact.
;   ( select Estados-table)
