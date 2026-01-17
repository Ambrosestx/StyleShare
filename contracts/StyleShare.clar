;; StyleShare - Decentralized Fashion Rental Marketplace
;; A smart contract for peer-to-peer fashion item rentals with escrow, reputation system, and dispute resolution

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
(define-constant ERR_DISPUTE_NOT_FOUND (err u111))
(define-constant ERR_DISPUTE_ALREADY_EXISTS (err u112))
(define-constant ERR_DISPUTE_ALREADY_RESOLVED (err u113))
(define-constant ERR_NOT_ARBITRATOR (err u114))
(define-constant ERR_ALREADY_VOTED (err u115))
(define-constant ERR_INVALID_VOTE (err u116))
(define-constant ERR_VOTING_PERIOD_ENDED (err u117))
(define-constant ERR_INSUFFICIENT_STAKE (err u118))
(define-constant ERR_ALREADY_ARBITRATOR (err u119))
(define-constant ERR_ARBITRATOR_NOT_FOUND (err u120))
(define-constant ERR_EMPTY_BATCH (err u121))
(define-constant ERR_BATCH_TOO_LARGE (err u122))
(define-constant ERR_CONTRACT_PAUSED (err u123))
(define-constant ERR_NO_FEES_TO_WITHDRAW (err u124))
(define-constant ERR_WITHDRAWAL_FAILED (err u125))

;; Constants for dispute system
(define-constant MIN_ARBITRATOR_STAKE u1000000) ;; 1 STX minimum stake
(define-constant DISPUTE_VOTING_PERIOD u1440) ;; ~10 days in blocks (assuming 10 min blocks)
(define-constant MIN_ARBITRATORS_FOR_RESOLUTION u3)

;; Constants for bulk operations
(define-constant MAX_BULK_ITEMS u10) ;; Maximum items per bulk operation

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
    rating-given: bool,
    dispute-id: (optional uint)
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

;; Dispute resolution system maps
(define-map disputes
  { dispute-id: uint }
  {
    rental-id: uint,
    complainant: principal,
    defendant: principal,
    reason: (string-ascii 500),
    created-block: uint,
    resolved: bool,
    resolution: (optional (string-ascii 200)),
    votes-for-complainant: uint,
    votes-for-defendant: uint,
    total-votes: uint
  }
)

(define-map arbitrators
  { arbitrator: principal }
  {
    stake-amount: uint,
    total-cases: uint,
    reputation-score: uint,
    active: bool
  }
)

(define-map arbitrator-votes
  { dispute-id: uint, arbitrator: principal }
  {
    vote: bool, ;; true for complainant, false for defendant
    reasoning: (string-ascii 300)
  }
)

;; Counters and state variables
(define-data-var next-item-id uint u1)
(define-data-var next-rental-id uint u1)
(define-data-var next-dispute-id uint u1)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points
(define-data-var total-arbitrators uint u0)
(define-data-var contract-paused bool false)
(define-data-var accumulated-fees uint u0) ;; Track platform fees

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

(define-private (is-valid-dispute-id (dispute-id uint))
  (and (> dispute-id u0) (< dispute-id (var-get next-dispute-id)))
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)

(define-private (is-voting-period-active (created-block uint))
  (<= (- stacks-block-height created-block) DISPUTE_VOTING_PERIOD)
)

(define-private (is-arbitrator (user principal))
  (match (map-get? arbitrators { arbitrator: user })
    arbitrator-data (get active arbitrator-data)
    false
  )
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

;; Emergency pause functions
(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused false)
    (ok true)
  )
)

;; Platform fee withdrawal function
(define-public (withdraw-platform-fees)
  (let ((fees (var-get accumulated-fees)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (> fees u0) ERR_NO_FEES_TO_WITHDRAW)
    
    ;; Reset accumulated fees before transfer to prevent reentrancy
    (var-set accumulated-fees u0)
    
    ;; Transfer fees to contract owner
    (match (as-contract (stx-transfer? fees tx-sender CONTRACT_OWNER))
      success (ok fees)
      error (begin
        ;; Restore fees on failure
        (var-set accumulated-fees fees)
        ERR_WITHDRAWAL_FAILED
      )
    )
  )
)

;; Public functions
(define-public (list-fashion-item (title (string-ascii 100)) (description (string-ascii 500)) 
                                  (category (string-ascii 50)) (size (string-ascii 10)) 
                                  (daily-rate uint) (security-deposit uint))
  (let ((item-id (var-get next-item-id)))
    (asserts! (not (var-get contract-paused)) ERR_CONTRACT_PAUSED)
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

;; Bulk listing helper function
(define-private (list-single-item-internal 
                  (item-data { title: (string-ascii 100), 
                              description: (string-ascii 500), 
                              category: (string-ascii 50), 
                              size: (string-ascii 10), 
                              daily-rate: uint, 
                              security-deposit: uint })
                  (acc (response (list 10 uint) uint)))
  (match acc
    success-list
      (match (list-fashion-item 
               (get title item-data)
               (get description item-data)
               (get category item-data)
               (get size item-data)
               (get daily-rate item-data)
               (get security-deposit item-data))
        item-id (ok (unwrap-panic (as-max-len? (append success-list item-id) u10)))
        error (err error)
      )
    error (err error)
  )
)

;; Bulk list items function
(define-public (bulk-list-items (items (list 10 { title: (string-ascii 100), 
                                                   description: (string-ascii 500), 
                                                   category: (string-ascii 50), 
                                                   size: (string-ascii 10), 
                                                   daily-rate: uint, 
                                                   security-deposit: uint })))
  (let ((items-count (len items)))
    (asserts! (not (var-get contract-paused)) ERR_CONTRACT_PAUSED)
    (asserts! (> items-count u0) ERR_EMPTY_BATCH)
    (asserts! (<= items-count MAX_BULK_ITEMS) ERR_BATCH_TOO_LARGE)
    
    (fold list-single-item-internal items (ok (list)))
  )
)

(define-public (rent-item (item-id uint) (duration-days uint))
  (let ((item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND))
        (rental-id (var-get next-rental-id))
        (total-cost (* (get daily-rate item) duration-days))
        (security-deposit (get security-deposit item))
        (total-payment (+ total-cost security-deposit)))
    
    (asserts! (not (var-get contract-paused)) ERR_CONTRACT_PAUSED)
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
        rating-given: false,
        dispute-id: none
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

;; Bulk rental helper function
(define-private (rent-single-item-internal 
                  (rental-request { item-id: uint, duration-days: uint })
                  (acc (response { rental-ids: (list 10 uint), total-payment: uint } uint)))
  (match acc
    success-data
      (match (rent-item (get item-id rental-request) (get duration-days rental-request))
        rental-id 
          (let ((item (unwrap-panic (map-get? fashion-items { item-id: (get item-id rental-request) })))
                (total-cost (* (get daily-rate item) (get duration-days rental-request)))
                (security-deposit (get security-deposit item))
                (item-payment (+ total-cost security-deposit)))
            (ok { 
              rental-ids: (unwrap-panic (as-max-len? (append (get rental-ids success-data) rental-id) u10)),
              total-payment: (+ (get total-payment success-data) item-payment)
            })
          )
        error (err error)
      )
    error (err error)
  )
)

;; Bulk rent items function
(define-public (bulk-rent-items (rental-requests (list 10 { item-id: uint, duration-days: uint })))
  (let ((requests-count (len rental-requests)))
    (asserts! (not (var-get contract-paused)) ERR_CONTRACT_PAUSED)
    (asserts! (> requests-count u0) ERR_EMPTY_BATCH)
    (asserts! (<= requests-count MAX_BULK_ITEMS) ERR_BATCH_TOO_LARGE)
    
    (match (fold rent-single-item-internal 
                 rental-requests 
                 (ok { rental-ids: (list), total-payment: u0 }))
      success (ok (get rental-ids success))
      error (err error)
    )
  )
)

(define-public (return-item (rental-id uint))
  (let ((rental (unwrap! (map-get? rentals { rental-id: rental-id }) ERR_RENTAL_NOT_FOUND))
        (item-id (get item-id rental))
        (item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_ITEM_NOT_FOUND)))
    
    (asserts! (is-valid-rental-id rental-id) ERR_RENTAL_NOT_FOUND)
    (asserts! (is-eq tx-sender (get renter rental)) ERR_UNAUTHORIZED)
    (asserts! (not (get returned rental)) ERR_RENTAL_ALREADY_RETURNED)
    
    ;; Check if there's an active dispute
    (asserts! (is-none (get dispute-id rental)) ERR_DISPUTE_ALREADY_EXISTS)
    
    ;; Calculate payments
    (let ((platform-fee (calculate-platform-fee (get total-cost rental)))
          (owner-payment (- (get total-cost rental) platform-fee)))
      
      ;; Accumulate platform fees
      (var-set accumulated-fees (+ (var-get accumulated-fees) platform-fee))
      
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

;; Dispute Resolution Functions
(define-public (register-arbitrator (stake-amount uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR_CONTRACT_PAUSED)
    (asserts! (>= stake-amount MIN_ARBITRATOR_STAKE) ERR_INSUFFICIENT_STAKE)
    (asserts! (not (is-arbitrator tx-sender)) ERR_ALREADY_ARBITRATOR)
    
    ;; Transfer stake to contract
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
    
    ;; Register arbitrator
    (map-set arbitrators
      { arbitrator: tx-sender }
      {
        stake-amount: stake-amount,
        total-cases: u0,
        reputation-score: u0,
        active: true
      }
    )
    
    ;; Update total arbitrators count
    (var-set total-arbitrators (+ (var-get total-arbitrators) u1))
    
    (ok true)
  )
)

(define-public (create-dispute (rental-id uint) (reason (string-ascii 500)))
  (let ((rental (unwrap! (map-get? rentals { rental-id: rental-id }) ERR_RENTAL_NOT_FOUND))
        (dispute-id (var-get next-dispute-id)))
    
    (asserts! (is-valid-rental-id rental-id) ERR_RENTAL_NOT_FOUND)
    (asserts! (is-valid-description reason) ERR_INVALID_PRICE)
    (asserts! (or (is-eq tx-sender (get renter rental)) (is-eq tx-sender (get owner rental))) ERR_UNAUTHORIZED)
    (asserts! (is-none (get dispute-id rental)) ERR_DISPUTE_ALREADY_EXISTS)
    (asserts! (not (get returned rental)) ERR_RENTAL_ALREADY_RETURNED)
    
    ;; Determine complainant and defendant
    (let ((complainant tx-sender)
          (defendant (if (is-eq tx-sender (get renter rental)) (get owner rental) (get renter rental))))
      
      ;; Create dispute record
      (map-set disputes
        { dispute-id: dispute-id }
        {
          rental-id: rental-id,
          complainant: complainant,
          defendant: defendant,
          reason: reason,
          created-block: stacks-block-height,
          resolved: false,
          resolution: none,
          votes-for-complainant: u0,
          votes-for-defendant: u0,
          total-votes: u0
        }
      )
      
      ;; Link dispute to rental
      (map-set rentals
        { rental-id: rental-id }
        (merge rental { dispute-id: (some dispute-id) })
      )
      
      ;; Update counter
      (var-set next-dispute-id (+ dispute-id u1))
      
      (ok dispute-id)
    )
  )
)

(define-public (vote-on-dispute (dispute-id uint) (vote-for-complainant bool) (reasoning (string-ascii 300)))
  (let ((dispute (unwrap! (map-get? disputes { dispute-id: dispute-id }) ERR_DISPUTE_NOT_FOUND)))
    
    (asserts! (is-valid-dispute-id dispute-id) ERR_DISPUTE_NOT_FOUND)
    (asserts! (is-arbitrator tx-sender) ERR_NOT_ARBITRATOR)
    (asserts! (not (get resolved dispute)) ERR_DISPUTE_ALREADY_RESOLVED)
    (asserts! (is-voting-period-active (get created-block dispute)) ERR_VOTING_PERIOD_ENDED)
    (asserts! (is-none (map-get? arbitrator-votes { dispute-id: dispute-id, arbitrator: tx-sender })) ERR_ALREADY_VOTED)
    (asserts! (> (len reasoning) u0) ERR_INVALID_VOTE)
    
    ;; Record the vote
    (map-set arbitrator-votes
      { dispute-id: dispute-id, arbitrator: tx-sender }
      {
        vote: vote-for-complainant,
        reasoning: reasoning
      }
    )
    
    ;; Update dispute vote counts
    (let ((new-complainant-votes (if vote-for-complainant 
                                    (+ (get votes-for-complainant dispute) u1)
                                    (get votes-for-complainant dispute)))
          (new-defendant-votes (if vote-for-complainant 
                                 (get votes-for-defendant dispute)
                                 (+ (get votes-for-defendant dispute) u1)))
          (new-total-votes (+ (get total-votes dispute) u1)))
      
      (map-set disputes
        { dispute-id: dispute-id }
        (merge dispute {
          votes-for-complainant: new-complainant-votes,
          votes-for-defendant: new-defendant-votes,
          total-votes: new-total-votes
        })
      )
      
      ;; Update arbitrator stats
      (let ((arbitrator-data (unwrap! (map-get? arbitrators { arbitrator: tx-sender }) ERR_ARBITRATOR_NOT_FOUND)))
        (map-set arbitrators
          { arbitrator: tx-sender }
          (merge arbitrator-data { total-cases: (+ (get total-cases arbitrator-data) u1) })
        )
      )
      
      (ok true)
    )
  )
)

(define-public (resolve-dispute (dispute-id uint))
  (let ((dispute (unwrap! (map-get? disputes { dispute-id: dispute-id }) ERR_DISPUTE_NOT_FOUND))
        (rental (unwrap! (map-get? rentals { rental-id: (get rental-id dispute) }) ERR_RENTAL_NOT_FOUND)))
    
    (asserts! (is-valid-dispute-id dispute-id) ERR_DISPUTE_NOT_FOUND)
    (asserts! (not (get resolved dispute)) ERR_DISPUTE_ALREADY_RESOLVED)
    (asserts! (>= (get total-votes dispute) MIN_ARBITRATORS_FOR_RESOLUTION) ERR_INSUFFICIENT_PAYMENT)
    (asserts! (not (is-voting-period-active (get created-block dispute))) ERR_VOTING_PERIOD_ENDED)
    
    ;; Determine winner based on votes
    (let ((complainant-wins (> (get votes-for-complainant dispute) (get votes-for-defendant dispute)))
          (platform-fee (calculate-platform-fee (get total-cost rental))))
      
      ;; Resolve dispute and distribute funds
      (if complainant-wins
        ;; Complainant wins - return funds to complainant
        (begin
          (try! (as-contract (stx-transfer? (+ (get total-cost rental) (get security-deposit rental)) 
                                           tx-sender (get complainant dispute))))
          (map-set disputes
            { dispute-id: dispute-id }
            (merge dispute { 
              resolved: true, 
              resolution: (some "Resolved in favor of complainant") 
            })
          )
        )
        ;; Defendant wins - pay defendant and return security deposit
        (begin
          (let ((owner-payment (- (get total-cost rental) platform-fee)))
            ;; Accumulate platform fees
            (var-set accumulated-fees (+ (var-get accumulated-fees) platform-fee))
            (try! (as-contract (stx-transfer? owner-payment tx-sender (get defendant dispute))))
            (try! (as-contract (stx-transfer? (get security-deposit rental) tx-sender (get complainant dispute))))
          )
          (map-set disputes
            { dispute-id: dispute-id }
            (merge dispute { 
              resolved: true, 
              resolution: (some "Resolved in favor of defendant") 
            })
          )
        )
      )
      
      ;; Mark rental as resolved
      (map-set rentals
        { rental-id: (get rental-id dispute) }
        (merge rental { returned: true })
      )
      
      ;; Make item available again
      (let ((item (unwrap! (map-get? fashion-items { item-id: (get item-id rental) }) ERR_ITEM_NOT_FOUND)))
        (map-set fashion-items
          { item-id: (get item-id rental) }
          (merge item { available: true })
        )
      )
      
      (ok true)
    )
  )
)

(define-public (deactivate-arbitrator)
  (let ((arbitrator-data (unwrap! (map-get? arbitrators { arbitrator: tx-sender }) ERR_ARBITRATOR_NOT_FOUND)))
    (asserts! (get active arbitrator-data) ERR_ARBITRATOR_NOT_FOUND)
    
    ;; Return stake to arbitrator
    (try! (as-contract (stx-transfer? (get stake-amount arbitrator-data) tx-sender tx-sender)))
    
    ;; Deactivate arbitrator
    (map-set arbitrators
      { arbitrator: tx-sender }
      (merge arbitrator-data { active: false })
    )
    
    ;; Update total arbitrators count
    (var-set total-arbitrators (- (var-get total-arbitrators) u1))
    
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

(define-read-only (get-dispute (dispute-id uint))
  (begin
    (asserts! (is-valid-dispute-id dispute-id) ERR_DISPUTE_NOT_FOUND)
    (ok (map-get? disputes { dispute-id: dispute-id }))
  )
)

(define-read-only (get-arbitrator (arbitrator principal))
  (map-get? arbitrators { arbitrator: arbitrator })
)

(define-read-only (get-arbitrator-vote (dispute-id uint) (arbitrator principal))
  (map-get? arbitrator-votes { dispute-id: dispute-id, arbitrator: arbitrator })
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

(define-read-only (get-next-dispute-id)
  (var-get next-dispute-id)
)

(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

(define-read-only (get-total-arbitrators)
  (var-get total-arbitrators)
)

(define-read-only (get-min-arbitrator-stake)
  MIN_ARBITRATOR_STAKE
)

(define-read-only (get-dispute-voting-period)
  DISPUTE_VOTING_PERIOD
)

(define-read-only (get-max-bulk-items)
  MAX_BULK_ITEMS
)

(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

(define-read-only (get-accumulated-fees)
  (var-get accumulated-fees)
)