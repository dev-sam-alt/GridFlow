;; energy-provider-certification.clar
;; Advanced certification system for renewable energy providers
;; Manages verification, compliance tracking, and performance metrics

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROVIDER_EXISTS (err u101))
(define-constant ERR_PROVIDER_NOT_FOUND (err u102))
(define-constant ERR_INVALID_PARAMETERS (err u103))
(define-constant ERR_CERTIFICATION_EXPIRED (err u104))

;; Administrative control
(define-data-var certification-authority principal tx-sender)
(define-data-var certification-validity-period uint u52560) ;; ~1 year in blocks
(define-data-var minimum-capacity-threshold uint u1000) ;; MW

;; Core provider registry with enhanced metadata
(define-map energy-provider-registry principal
  {
    provider-name: (string-utf8 100),
    certification-status: (string-ascii 20),
    registration-block: uint,
    expiry-block: uint,
    operational-region: (string-utf8 50),
    energy-capacity: uint,
    technology-type: (string-utf8 30),
    compliance-score: uint,
    last-audit-block: uint
  }
)

;; Performance tracking
(define-map provider-performance-metrics principal
  {
    total-energy-produced: uint,
    reliability-rating: uint,
    carbon-offset: uint,
    grid-stability-score: uint
  }
)

;; Certification levels
(define-map certification-tiers (string-ascii 20) uint)

;; Initialize certification tiers
(map-set certification-tiers "PROVISIONAL" u1)
(map-set certification-tiers "CERTIFIED" u2)
(map-set certification-tiers "PREMIUM" u3)
(map-set certification-tiers "ELITE" u4)

;; Register new energy provider with comprehensive validation
(define-public (register-energy-provider 
    (provider-address principal)
    (provider-name (string-utf8 100))
    (operational-region (string-utf8 50))
    (energy-capacity uint)
    (technology-type (string-utf8 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? energy-provider-registry provider-address)) ERR_PROVIDER_EXISTS)
    (asserts! (>= energy-capacity (var-get minimum-capacity-threshold)) ERR_INVALID_PARAMETERS)
    
    (let ((expiry-block (+ block-height (var-get certification-validity-period))))
      (map-set energy-provider-registry provider-address
        {
          provider-name: provider-name,
          certification-status: "PROVISIONAL",
          registration-block: block-height,
          expiry-block: expiry-block,
          operational-region: operational-region,
          energy-capacity: energy-capacity,
          technology-type: technology-type,
          compliance-score: u75,
          last-audit-block: block-height
        }
      )
      
      ;; Initialize performance metrics
      (map-set provider-performance-metrics provider-address
        {
          total-energy-produced: u0,
          reliability-rating: u50,
          carbon-offset: u0,
          grid-stability-score: u50
        }
      )
    )
    (ok true)
  )
)

;; Upgrade certification tier based on performance
(define-public (upgrade-certification-tier 
    (provider-address principal)
    (new-tier (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? energy-provider-registry provider-address)) ERR_PROVIDER_NOT_FOUND)
    (asserts! (is-some (map-get? certification-tiers new-tier)) ERR_INVALID_PARAMETERS)
    
    (let ((provider-data (unwrap-panic (map-get? energy-provider-registry provider-address))))
      (map-set energy-provider-registry provider-address
        (merge provider-data { 
          certification-status: new-tier,
          last-audit-block: block-height
        })
      )
    )
    (ok true)
  )
)

;; Update provider performance metrics
(define-public (update-performance-metrics
    (provider-address principal)
    (energy-produced uint)
    (reliability-rating uint)
    (carbon-offset uint)
    (grid-stability-score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? energy-provider-registry provider-address)) ERR_PROVIDER_NOT_FOUND)
    
    (let ((current-metrics (default-to 
            { total-energy-produced: u0, reliability-rating: u0, carbon-offset: u0, grid-stability-score: u0 }
            (map-get? provider-performance-metrics provider-address))))
      (map-set provider-performance-metrics provider-address
        {
          total-energy-produced: (+ (get total-energy-produced current-metrics) energy-produced),
          reliability-rating: reliability-rating,
          carbon-offset: (+ (get carbon-offset current-metrics) carbon-offset),
          grid-stability-score: grid-stability-score
        }
      )
    )
    (ok true)
  )
)

;; Renew provider certification
(define-public (renew-provider-certification (provider-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? energy-provider-registry provider-address)) ERR_PROVIDER_NOT_FOUND)
    
    (let ((provider-data (unwrap-panic (map-get? energy-provider-registry provider-address)))
          (new-expiry (+ block-height (var-get certification-validity-period))))
      (map-set energy-provider-registry provider-address
        (merge provider-data { 
          expiry-block: new-expiry,
          last-audit-block: block-height
        })
      )
    )
    (ok true)
  )
)

;; Suspend provider certification
(define-public (suspend-provider-certification (provider-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? energy-provider-registry provider-address)) ERR_PROVIDER_NOT_FOUND)
    
    (let ((provider-data (unwrap-panic (map-get? energy-provider-registry provider-address))))
      (map-set energy-provider-registry provider-address
        (merge provider-data { 
          certification-status: "SUSPENDED",
          last-audit-block: block-height
        })
      )
    )
    (ok true)
  )
)

;; Read-only functions

;; Check if provider certification is currently valid
(define-read-only (is-provider-certified (provider-address principal))
  (match (map-get? energy-provider-registry provider-address)
    provider-data (and 
      (not (is-eq (get certification-status provider-data) "SUSPENDED"))
      (< block-height (get expiry-block provider-data)))
    false
  )
)

;; Get comprehensive provider information
(define-read-only (get-provider-details (provider-address principal))
  (map-get? energy-provider-registry provider-address)
)

;; Get provider performance metrics
(define-read-only (get-provider-performance (provider-address principal))
  (map-get? provider-performance-metrics provider-address)
)

;; Get certification tier level
(define-read-only (get-certification-tier-level (tier-name (string-ascii 20)))
  (map-get? certification-tiers tier-name)
)

;; Check if certification needs renewal soon
(define-read-only (needs-renewal-soon (provider-address principal))
  (match (map-get? energy-provider-registry provider-address)
    provider-data 
      (let ((blocks-until-expiry (- (get expiry-block provider-data) block-height)))
        (< blocks-until-expiry u5256)) ;; ~10% of validity period
    false
  )
)

;; Administrative functions

;; Transfer certification authority
(define-public (transfer-certification-authority (new-authority principal))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (var-set certification-authority new-authority)
    (ok true)
  )
)

;; Update certification parameters
(define-public (update-certification-parameters 
    (validity-period uint)
    (capacity-threshold uint))
  (begin
    (asserts! (is-eq tx-sender (var-get certification-authority)) ERR_UNAUTHORIZED)
    (var-set certification-validity-period validity-period)
    (var-set minimum-capacity-threshold capacity-threshold)
    (ok true)
  )
)

;; Get current certification authority
(define-read-only (get-certification-authority)
  (var-get certification-authority)
)

;; Get certification parameters
(define-read-only (get-certification-parameters)
  {
    validity-period: (var-get certification-validity-period),
    capacity-threshold: (var-get minimum-capacity-threshold),
    authority: (var-get certification-authority)
  }
)