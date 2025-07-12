;; StyleShare - Decentralized Fashion Rental Marketplace
;; A smart contract for peer-to-peer fashion item rentals with escrow and reputation system

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ITEM_NOT_FOUND (err u101))
(define-constant ERR_ITEM_NOT_AVAILABLE (err u102))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u103))
(define-constant ERR_RENTAL_NOT_FOUND (err u104))
(define-constant ERR_RENTAL_ALREADY_RETURNED (err u105))
(define-constant ERR_INVALID_DURATION (err u106))
(define-constant ERR_INVALID_PRICE (err u107))
(define-constant ERR_SELF_RENTAL (err u108))
(define-constant ERR_RENTAL_ACTIVE (err u109))
(define-constant ERR_INVALID_RATING (err u110))

;; Data structures
(define-map fashion-items
  { item-id: uint }
  {
    owner: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    category: (string-ascii 50),
    size: (string-ascii 10),
    daily-rate: uint,
    security-deposit: uint,
    available: bool,
    total-rentals: uint,
    average-rating: uint
  }
)

(define-map rentals
  { rental-id: uint }
  {
    item-id: uint,
    renter: principal,
    owner: principal,
    start-block: uint,
    duration-days: uint,
    total-cost: uint,
    security-deposit: uint,
    returned: bool,
    rating-given: bool
  }
)

(define-map user-profiles
  { user: principal }
  {
    total-rentals: uint,
    total-items-rented: uint,
    reputation-score: uint,
    total-earned: uint
  }
)

;; Counters
(define-data-var next-item-id uint u1)
(define-data-var next-rental-id uint u1)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points

;; Helper functions
(define-private (is-valid-string (str (string-ascii 100)))
  (> (len str) u0)
)

(define-private (is-valid-description (desc (string-ascii 500)))
  (> (len desc) u0)
)

(define-private (is-valid-category (cat (string-ascii 50)))
  (> (len cat) u0)
)

(define-private (is-valid-size (sz (string-ascii 10)))
  (> (len sz) u0)
)

(define-private (is-valid-price (price uint))
  (> price u0)
)

(define-private (is-valid-duration (duration uint))
  (and (> duration u0) (<= duration u365))
)

(define-private (is-valid-rating (rating uint))
  (and (>= rating u1) (<= rating u5))
)

(define-private (is-valid-item-id (item-id uint))
  (and (> item-id u0) (< item-id (var-get next-item-id)))
)

(define-private (is-valid-rental-id (rental-id uint))
  (and (> rental-id u0) (< rental-id (var-get next-rental-id)))
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)

(define-private (update-user-profile (user principal) (rental-count uint) (items-rented uint) (earnings uint))
  (let ((profile (default-to 
                   { total-rentals: u0, total-items-rented: u0, reputation-score: u0, total-earned: u0 }
                   (map-get? user-profiles { user: user }))))
    (map-set user-profiles
      { user: user }
      {
        total-rentals: (+ (get total-rentals profile) rental-count),
        total-items-rented: (+ (get total-items-rented profile) items-rented),
        reputation-score: (get reputation-score profile),
        total-earned: (+ (get total-earned profile) earnings)
      }
    )
  )
)

;; Public functions
(define-public (list-fashion-item (title (string-ascii 100)) (description (string-ascii 500)) 
                                  (category (string-ascii 50)) (size (string-ascii 10)) 
                                  (daily-rate uint) (security-deposit uint))
  (let ((item-id (var-get next-item-id)))
    (asserts! (is-valid-string title) ERR_INVALID_PRICE)
    (asserts! (is-valid-description description) ERR_INVALID_PRICE)
    (asserts! (is-valid-category category) ERR_INVALID_PRICE)
    (asserts! (is-valid-size size) ERR_INVALID_PRICE)
    (asserts! (is-valid-price daily-rate) ERR_INVALID_PRICE)
    (asserts! (is-valid-price security-deposit) ERR_INVALID_PRICE)
    
    (map-set fashion-items
      { item-id: item-id }
      {
        owner: tx-sender,
        title: title,
        description: description,
        category: category,
        size: size,
        daily-rate: daily-rate,
        security-deposit: security-deposit,
        available: true,
        total-rentals: u0,
        average-rating: u0
      }
    )
    
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

(define-public (rent-item (item-id uint) (duration-days uint))
  (let ((item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND))
        (rental-id (var-get next-rental-id))
        (total-cost (* (get daily-rate item) duration-days))
        (security-deposit (get security-deposit item))
        (total-payment (+ total-cost security-deposit)))
    
    (asserts! (is-valid-item-id item-id) ERR_ITEM_NOT_FOUND)
    (asserts! (get available item) ERR_ITEM_NOT_AVAILABLE)
    (asserts! (is-valid-duration duration-days) ERR_INVALID_DURATION)
    (asserts! (not (is-eq tx-sender (get owner item))) ERR_SELF_RENTAL)
    
    ;; Transfer payment to contract for escrow
    (try! (stx-transfer? total-payment tx-sender (as-contract tx-sender)))
    
    ;; Create rental record
    (map-set rentals
      { rental-id: rental-id }
      {
        item-id: item-id,
        renter: tx-sender,
        owner: (get owner item),
        start-block: stacks-block-height,
        duration-days: duration-days,
        total-cost: total-cost,
        security-deposit: security-deposit,
        returned: false,
        rating-given: false
      }
    )
    
    ;; Mark item as unavailable
    (map-set fashion-items
      { item-id: item-id }
      (merge item { available: false })
    )
    
    ;; Update counters
    (var-set next-rental-id (+ rental-id u1))
    
    ;; Update user profile
    (update-user-profile tx-sender u0 u1 u0)
    
    (ok rental-id)
  )
)

(define-public (return-item (rental-id uint))
  (let ((rental (unwrap! (map-get? rentals { rental-id: rental-id }) ERR_RENTAL_NOT_FOUND))
        (item-id (get item-id rental))
        (item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND)))
    
    (asserts! (is-valid-rental-id rental-id) ERR_RENTAL_NOT_FOUND)
    (asserts! (is-eq tx-sender (get renter rental)) ERR_UNAUTHORIZED)
    (asserts! (not (get returned rental)) ERR_RENTAL_ALREADY_RETURNED)
    
    ;; Calculate payments
    (let ((platform-fee (calculate-platform-fee (get total-cost rental)))
          (owner-payment (- (get total-cost rental) platform-fee)))
      
      ;; Transfer payment to owner
      (try! (as-contract (stx-transfer? owner-payment tx-sender (get owner rental))))
      
      ;; Return security deposit to renter
      (try! (as-contract (stx-transfer? (get security-deposit rental) tx-sender (get renter rental))))
      
      ;; Mark rental as returned
      (map-set rentals
        { rental-id: rental-id }
        (merge rental { returned: true })
      )
      
      ;; Mark item as available
      (map-set fashion-items
        { item-id: item-id }
        (merge item { 
          available: true, 
          total-rentals: (+ (get total-rentals item) u1) 
        })
      )
      
      ;; Update owner profile
      (update-user-profile (get owner rental) u1 u0 owner-payment)
      
      (ok true)
    )
  )
)

(define-public (rate-rental (rental-id uint) (rating uint))
  (let ((rental (unwrap! (map-get? rentals { rental-id: rental-id }) ERR_RENTAL_NOT_FOUND))
        (item-id (get item-id rental))
        (item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND)))
    
    (asserts! (is-valid-rental-id rental-id) ERR_RENTAL_NOT_FOUND)
    (asserts! (is-valid-rating rating) ERR_INVALID_RATING)
    (asserts! (is-eq tx-sender (get renter rental)) ERR_UNAUTHORIZED)
    (asserts! (get returned rental) ERR_RENTAL_ACTIVE)
    (asserts! (not (get rating-given rental)) ERR_RENTAL_ALREADY_RETURNED)
    
    ;; Calculate new average rating
    (let ((current-rating (get average-rating item))
          (total-rentals (get total-rentals item))
          (new-average (if (is-eq current-rating u0)
                          rating
                          (/ (+ (* current-rating total-rentals) rating) (+ total-rentals u1)))))
      
      ;; Update item rating
      (map-set fashion-items
        { item-id: item-id }
        (merge item { average-rating: new-average })
      )
      
      ;; Mark rating as given
      (map-set rentals
        { rental-id: rental-id }
        (merge rental { rating-given: true })
      )
      
      (ok true)
    )
  )
)

(define-public (update-item-availability (item-id uint) (available bool))
  (let ((item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND)))
    (asserts! (is-valid-item-id item-id) ERR_ITEM_NOT_FOUND)
    (asserts! (is-eq tx-sender (get owner item)) ERR_UNAUTHORIZED)
    
    (map-set fashion-items
      { item-id: item-id }
      (merge item { available: available })
    )
    
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-fashion-item (item-id uint))
  (begin
    (asserts! (is-valid-item-id item-id) ERR_ITEM_NOT_FOUND)
    (ok (map-get? fashion-items { item-id: item-id }))
  )
)

(define-read-only (get-rental (rental-id uint))
  (begin
    (asserts! (is-valid-rental-id rental-id) ERR_RENTAL_NOT_FOUND)
    (ok (map-get? rentals { rental-id: rental-id }))
  )
)

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles { user: user })
)

(define-read-only (get-next-item-id)
  (var-get next-item-id)
)

(define-read-only (get-next-rental-id)
  (var-get next-rental-id)
)

(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)