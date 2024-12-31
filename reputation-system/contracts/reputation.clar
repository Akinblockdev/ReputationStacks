;; Reputation System Contract
;; Allows users to earn reputation through staking and reviews

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REVIEWED (err u101))
(define-constant ERR-INSUFFICIENT-STAKE (err u102))
(define-constant ERR-INVALID-RATING (err u103))
(define-constant ERR-INVALID-PRINCIPAL (err u104))
(define-constant MIN-STAKE-AMOUNT u1000)
(define-constant MAX-RATING u5)

;; Data vars
(define-data-var admin principal tx-sender)
(define-data-var total-staked uint u0)

;; Maps
(define-map user-stakes principal uint)
(define-map reputation-scores principal uint)
(define-map reviews 
    {reviewer: principal, subject: principal} 
    {rating: uint, timestamp: uint})
(define-map user-review-count principal uint)

;; Helper functions
(define-private (validate-principal (address principal))
    (match (principal-destruct? address)
        success true
        error false))

;; Read-only functions
(define-read-only (get-stake (user principal))
    (default-to u0 (map-get? user-stakes user)))

(define-read-only (get-reputation (user principal))
    (default-to u0 (map-get? reputation-scores user)))

(define-read-only (get-review (reviewer principal) (subject principal))
    (map-get? reviews {reviewer: reviewer, subject: subject}))

;; Public functions
(define-public (stake (amount uint))
    (begin
        (asserts! (>= amount MIN-STAKE-AMOUNT) ERR-INSUFFICIENT-STAKE)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set user-stakes tx-sender 
            (+ (get-stake tx-sender) amount))
        (var-set total-staked (+ (var-get total-staked) amount))
        (ok true)))

(define-public (submit-review (subject principal) (rating uint))
    (begin
        (asserts! (> (get-stake tx-sender) u0) ERR-INSUFFICIENT-STAKE)
        (asserts! (<= rating MAX-RATING) ERR-INVALID-RATING)
        (asserts! (is-none (get-review tx-sender subject)) ERR-ALREADY-REVIEWED)
        (asserts! (validate-principal subject) ERR-INVALID-PRINCIPAL)
        
        ;; Update review data
        (map-set reviews 
            {reviewer: tx-sender, subject: subject}
            {rating: rating, timestamp: block-height})
        
        ;; Update review count
        (map-set user-review-count subject
            (+ (default-to u0 (map-get? user-review-count subject)) u1))
        
        ;; Update reputation score
        (map-set reputation-scores subject
            (+ (get-reputation subject) rating))
        
        (ok true)))

(define-public (unstake (amount uint))
    (let ((current-stake (get-stake tx-sender)))
        (begin
            (asserts! (>= current-stake amount) ERR-INSUFFICIENT-STAKE)
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
            (map-set user-stakes tx-sender (- current-stake amount))
            (var-set total-staked (- (var-get total-staked) amount))
            (ok true))))

(define-public (update-admin (new-admin principal))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
        (asserts! (validate-principal new-admin) ERR-INVALID-PRINCIPAL)
        (var-set admin new-admin)
        (ok true)))