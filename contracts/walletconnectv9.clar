;; v9 - Reown Ready (Bulletproof Edition)
(define-non-fungible-token VIP-MEMBERSHIP uint)

(define-data-var last-id uint u0)
(define-map user-contributions principal uint)

;; 1. DONATE (Hemos añadido el recipient para evitar errores de cuenta propia)
(define-public (donate (amount uint) (recipient principal))
    (begin
        ;; Asegúrate de que el recipient NO sea tu propia dirección para probar
        (try! (stx-transfer? amount tx-sender recipient))
        (map-set user-contributions tx-sender (+ (default-to u0 (map-get? user-contributions tx-sender)) amount))
        (ok true)
    )
)

;; 2. CLAIM NFT
(define-public (claim-membership)
    (let 
        (
            (total (default-to u0 (map-get? user-contributions tx-sender)))
            (new-id (+ (var-get last-id) u1))
        )
        ;; Bajamos el requisito a 1 STX (u1000000) solo para TESTEAR que funcione
        (asserts! (>= total u1000000) (err u403))
        
        (try! (nft-mint? VIP-MEMBERSHIP new-id tx-sender))
        (var-set last-id new-id)
        (ok new-id)
    )
)

;; 3. GET STATS
(define-read-only (get-stats (user principal))
    {
        donated: (default-to u0 (map-get? user-contributions user)),
        id: (var-get last-id)
    }
)
