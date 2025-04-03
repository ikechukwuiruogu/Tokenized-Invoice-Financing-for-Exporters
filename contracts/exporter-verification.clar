;; Exporter Verification Contract
;; This contract validates legitimate businesses for participation in the system

(define-data-var admin principal tx-sender)

;; Data map to store verified exporters
(define-map verified-exporters
  principal
  {
    business-name: (string-utf8 100),
    registration-number: (string-utf8 50),
    country: (string-utf8 50),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a new exporter (self-registration)
(define-public (register-exporter (business-name (string-utf8 100)) (registration-number (string-utf8 50)) (country (string-utf8 50)))
  (begin
    (asserts! (not (is-some (map-get? verified-exporters tx-sender))) (err u1)) ;; Error if already registered
    (ok (map-set verified-exporters tx-sender {
      business-name: business-name,
      registration-number: registration-number,
      country: country,
      verified: false,
      verification-date: u0
    }))
  )
)

;; Admin function to verify an exporter
(define-public (verify-exporter (exporter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2)) ;; Only admin can verify
    (asserts! (is-some (map-get? verified-exporters exporter)) (err u3)) ;; Exporter must be registered
    (ok (map-set verified-exporters exporter
      (merge (unwrap-panic (map-get? verified-exporters exporter))
        {
          verified: true,
          verification-date: block-height
        }
      )
    ))
  )
)

;; Read-only function to check if an exporter is verified
(define-read-only (is-verified-exporter (exporter principal))
  (match (map-get? verified-exporters exporter)
    exporter-data (get verified exporter-data)
    false
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u4)) ;; Only current admin can transfer
    (ok (var-set admin new-admin))
  )
)
