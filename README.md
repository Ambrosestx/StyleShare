# StyleShare 

A decentralized fashion rental marketplace built on Stacks blockchain, enabling peer-to-peer fashion item rentals with built-in escrow, reputation systems, and community-driven dispute resolution.

## Overview

StyleShare revolutionizes fashion accessibility by creating a trustless marketplace where users can rent and lend high-quality fashion items. The platform uses smart contracts to handle payments, security deposits, reputation tracking, and dispute resolution automatically through a decentralized arbitration system.

## Features

- **Fashion Item Listing**: Users can list their fashion items with detailed descriptions, pricing, and availability
- **Bulk Operations**: List up to 10 items at once or rent multiple items in a single transaction for improved efficiency
- **Secure Rental System**: Automated escrow system holds payments and security deposits until items are returned
- **Reputation System**: Built-in rating system for items and users to build trust in the marketplace
- **Dispute Resolution System**: Multi-signature arbitration system for rental conflicts with community-voted arbitrators
- **Emergency Pause Mechanism**: Contract owner can pause operations for maintenance or security incidents
- **Multi-Category Support**: Supports various fashion categories with size specifications
- **Flexible Duration**: Rental periods from 1 day up to 365 days
- **Platform Fee Structure**: Transparent 2.5% platform fee on successful rentals

## Smart Contract Functions

### Public Functions

**Core Marketplace Functions:**
- `list-fashion-item`: List a new fashion item for rent
- `bulk-list-items`: List multiple fashion items (up to 10) in a single transaction
- `rent-item`: Rent an available fashion item
- `bulk-rent-items`: Rent multiple items (up to 10) in a single transaction
- `return-item`: Return a rented item and complete the transaction
- `rate-rental`: Rate a completed rental experience
- `update-item-availability`: Toggle item availability

**Dispute Resolution Functions:**
- `register-arbitrator`: Register as a community arbitrator with stake
- `create-dispute`: Create a dispute for a rental conflict
- `vote-on-dispute`: Vote on dispute resolution (arbitrators only)
- `resolve-dispute`: Execute dispute resolution based on community votes
- `deactivate-arbitrator`: Deactivate arbitrator status and retrieve stake

**Emergency Functions:**
- `pause-contract`: Pause all marketplace operations (owner only)
- `unpause-contract`: Resume marketplace operations (owner only)

### Read-Only Functions

- `get-fashion-item`: Retrieve item details
- `get-rental`: Get rental information
- `get-dispute`: View dispute details and voting status
- `get-arbitrator`: Get arbitrator information and statistics
- `get-arbitrator-vote`: View specific arbitrator's vote on a dispute
- `get-user-profile`: View user statistics and reputation
- `get-next-item-id`: Current item counter
- `get-next-rental-id`: Current rental counter
- `get-next-dispute-id`: Current dispute counter
- `get-platform-fee-rate`: Current platform fee rate
- `get-total-arbitrators`: Number of active arbitrators
- `get-min-arbitrator-stake`: Minimum stake required for arbitrators
- `get-dispute-voting-period`: Voting period duration for disputes
- `get-max-bulk-items`: Maximum items allowed in bulk operations
- `is-contract-paused`: Check if contract is currently paused

## Emergency Pause System

### Overview
The emergency pause mechanism allows the contract owner to temporarily halt all marketplace operations during critical situations such as:
- Security vulnerabilities or exploits
- Planned maintenance and upgrades
- Regulatory compliance requirements
- Emergency bug fixes

### How It Works

**Pausing the Contract:**
- Only the contract owner can pause operations
- Call `pause-contract` to activate emergency pause
- All marketplace operations (listing, renting, arbitrator registration, bulk operations) are immediately blocked
- Ongoing rentals can still be returned and disputes can still be resolved

**Unpause Operations:**
- Only the contract owner can unpause
- Call `unpause-contract` to resume normal operations
- All functions become available again immediately

**Protected Operations:**
The following operations are blocked during pause:
- `list-fashion-item`
- `bulk-list-items`
- `rent-item`
- `bulk-rent-items`
- `register-arbitrator`

**Allowed Operations During Pause:**
Critical user functions remain available:
- `return-item` - Users can return items and receive refunds
- `rate-rental` - Users can rate completed rentals
- `create-dispute` - Users can create disputes for protection
- `vote-on-dispute` - Arbitrators can continue voting
- `resolve-dispute` - Disputes can be resolved
- `deactivate-arbitrator` - Arbitrators can withdraw stakes
- `update-item-availability` - Owners can manage their items
- All read-only functions remain available

### Use Cases

**Security Incident:**
```clarity
;; Contract owner detects a potential exploit
(pause-contract)
;; Investigate and fix the issue
;; Deploy patch or mitigation
(unpause-contract)
```

**Planned Maintenance:**
```clarity
;; Before major upgrade or migration
(pause-contract)
;; Perform maintenance tasks
;; Test new features
(unpause-contract)
```

**Emergency Response:**
```clarity
;; Rapid response to critical bug
(pause-contract)
;; Allow users to safely exit positions
;; Disputes continue to resolve
;; Implement fix
(unpause-contract)
```

## Data Structures

### Fashion Items
- Item ID, owner, title, description
- Category, size, daily rate, security deposit
- Availability status, rental history, ratings

### Rentals
- Rental ID, item reference, renter/owner info
- Rental period, costs, return status
- Rating system integration, dispute linking

### User Profiles
- Rental statistics, reputation scores
- Total earnings, transaction history

### Disputes
- Dispute ID, rental reference, parties involved
- Complaint reason, voting results, resolution status
- Community arbitration outcomes

### Arbitrators
- Stake amount, case history, reputation scores
- Active status, voting participation

## Bulk Operations

### Bulk Listing Items
The `bulk-list-items` function allows users to list up to 10 fashion items in a single transaction, significantly reducing gas costs and improving user experience for sellers with multiple items.

**Function Signature:**
```clarity
(bulk-list-items 
  (list 10 { 
    title: (string-ascii 100), 
    description: (string-ascii 500), 
    category: (string-ascii 50), 
    size: (string-ascii 10), 
    daily-rate: uint, 
    security-deposit: uint 
  }))
```

**Parameters:**
- A list of item data structures (1-10 items)
- Each item requires: title, description, category, size, daily-rate, and security-deposit

**Returns:**
- Success: List of newly created item IDs
- Error: Appropriate error code if validation fails

**Benefits:**
- **Reduced Transaction Costs**: Single transaction fee instead of multiple
- **Faster Onboarding**: New sellers can list entire wardrobes quickly
- **Improved Efficiency**: Power users can manage inventory efficiently
- **Atomic Operation**: All items listed successfully or none at all

**Example Use Case:**
A fashion influencer wants to list 5 designer pieces from their closet. Instead of creating 5 separate transactions, they can bundle all items into one `bulk-list-items` call, saving time and transaction fees.

### Bulk Renting Items
The `bulk-rent-items` function enables renters to rent multiple items simultaneously, perfect for event outfits or coordinated wardrobes.

**Function Signature:**
```clarity
(bulk-rent-items 
  (list 10 { 
    item-id: uint, 
    duration-days: uint 
  }))
```

**Parameters:**
- A list of rental requests (1-10 items)
- Each request requires: item-id and duration-days

**Returns:**
- Success: List of newly created rental IDs
- Error: Appropriate error code if any item is unavailable or validation fails

**Benefits:**
- **Single Transaction**: Complete multiple rentals at once
- **Atomic Execution**: All rentals succeed together or fail together
- **Simplified Payment**: One payment for all items
- **Better UX**: Ideal for event planning and outfit coordination
- **Cost Effective**: Reduced gas fees compared to individual rentals

**Example Use Case:**
A user needs an outfit for a wedding: dress, shoes, and accessories. They can rent all 3 items in one transaction using `bulk-rent-items`, ensuring they get the complete look with a single payment.

### Bulk Operation Limits
- **Maximum Items**: 10 items per bulk operation
- **Minimum Items**: 1 item (empty batches rejected with `ERR_EMPTY_BATCH`)
- **Validation**: All items validated before any operation executes
- **Error Handling**: If any item fails validation, entire batch fails
- **Pause Aware**: Bulk operations respect contract pause state

## Dispute Resolution System

### How It Works
1. **Arbitrator Registration**: Community members can register as arbitrators by staking a minimum of 1 STX
2. **Dispute Creation**: Either party in a rental can create a dispute with detailed reasoning
3. **Community Voting**: Active arbitrators vote on disputes within a 10-day voting period
4. **Resolution**: Disputes are resolved based on majority vote with minimum 3 arbitrators participating
5. **Automatic Distribution**: Funds are automatically distributed based on dispute outcome

### Arbitrator Requirements
- **Minimum Stake**: 1 STX required to become an arbitrator
- **Voting Period**: 10 days (~1440 blocks) to cast votes on disputes
- **Minimum Participation**: At least 3 arbitrators must vote for resolution
- **Reputation System**: Track record of arbitration decisions

## Getting Started

### For Item Owners
1. Deploy or connect to the StyleShare contract
2. **Single Item**: Use `list-fashion-item` with item details
3. **Multiple Items**: Use `bulk-list-items` with array of item data
4. Set competitive daily rates and security deposits
5. Manage item availability as needed

### For Renters
1. Browse available fashion items
2. **Single Rental**: Use `rent-item` with item ID and duration
3. **Multiple Rentals**: Use `bulk-rent-items` with array of rental requests
4. Complete payment (rental cost + security deposit)
5. Return items on time to maintain good reputation
6. Rate your rental experience

### For Arbitrators
1. Register using `register-arbitrator` with minimum 1 STX stake
2. Review open disputes in the system
3. Vote on disputes with reasoned decisions
4. Build reputation through fair arbitration
5. Deactivate and retrieve stake when needed

## Security Features

- **Input Validation**: All parameters validated before processing
- **Proper Error Handling**: Descriptive error codes for all failure cases
- **Escrow System**: Payments held securely until item return or dispute resolution
- **Security Deposits**: Protect item owners from damage or loss
- **Reputation System**: Builds trust and accountability over time
- **Staked Arbitration**: Economic incentives ensure fair dispute resolution
- **Time-Locked Voting**: Prevents manipulation of dispute outcomes
- **Atomic Operations**: Bulk operations succeed completely or fail completely
- **No Unchecked Data**: All data properly validated throughout execution
- **Emergency Pause**: Circuit breaker for security incidents
- **Owner Controls**: Critical admin functions protected by ownership checks

## Error Codes

**Core System:**
- `u100`: Unauthorized access
- `u101`: Item not found
- `u102`: Item not available
- `u103`: Insufficient payment
- `u104`: Rental not found
- `u105`: Rental already returned
- `u106`: Invalid duration (must be 1-365 days)
- `u107`: Invalid price (must be greater than 0)
- `u108`: Self-rental attempt (cannot rent your own items)
- `u109`: Rental still active
- `u110`: Invalid rating (must be 1-5)

**Dispute Resolution:**
- `u111`: Dispute not found
- `u112`: Dispute already exists for this rental
- `u113`: Dispute already resolved
- `u114`: Not an arbitrator
- `u115`: Already voted on this dispute
- `u116`: Invalid vote
- `u117`: Voting period ended
- `u118`: Insufficient stake (minimum 1 STX required)
- `u119`: Already an arbitrator
- `u120`: Arbitrator not found

**Bulk Operations:**
- `u121`: Empty batch - no items provided
- `u122`: Batch too large - exceeds maximum of 10 items

**Emergency Controls:**
- `u123`: Contract paused - operations temporarily disabled

## Platform Economics

- **Platform Fee**: 2.5% of rental cost (250 basis points)
- **Security Deposits**: Set individually by item owners
- **Payment Flow**: Automatic distribution upon item return or dispute resolution
- **Rating System**: 1-5 star ratings for quality assurance
- **Arbitrator Staking**: Minimum 1 STX stake (1,000,000 microSTX)
- **Dispute Resolution**: Community-driven with economic incentives for fair arbitration
- **Bulk Discounts**: Reduced per-item transaction costs through batching

## Benefits of Emergency Pause

### For Users
- **Protection**: Operations halt during security incidents
- **Confidence**: Know the platform can respond to threats
- **Safe Exit**: Can still return items and resolve disputes
- **Transparency**: Pause state visible to all users

### For Contract Owner
- **Security Response**: Quick reaction to vulnerabilities
- **Maintenance Window**: Safe environment for upgrades
- **Risk Management**: Control over critical situations
- **Compliance**: Meet regulatory requirements when needed

### For the Platform
- **Security**: Circuit breaker for emergency situations
- **Stability**: Controlled maintenance windows
- **Trust**: Demonstrates responsible platform management
- **Flexibility**: Adapt to changing conditions safely

## Benefits of Bulk Operations

### For Power Users
- **Efficiency**: Manage multiple items without repetitive transactions
- **Cost Savings**: Significant reduction in total gas fees
- **Time Savings**: Complete workflows faster
- **Better Cash Flow**: Single payment process for multiple items

### For Event Planners
- **Complete Outfits**: Rent coordinated looks in one transaction
- **Guaranteed Availability**: Atomic rental ensures all items or none
- **Simplified Budgeting**: Single payment for entire outfit
- **Reduced Risk**: All-or-nothing approach prevents partial outfits

### For Fashion Sellers
- **Quick Inventory Setup**: List entire collections rapidly
- **Lower Barrier to Entry**: Easier onboarding for new sellers
- **Professional Experience**: Enterprise-grade bulk features
- **Reduced Overhead**: Less time managing individual listings

### For the Platform
- **Scalability**: Handle high-volume users efficiently
- **Network Efficiency**: Fewer transactions reduce blockchain congestion
- **Competitive Edge**: Modern feature set attracts power users
- **Better UX**: Professional features improve user satisfaction

## Benefits of Dispute Resolution System

### For Users
- **Fair Resolution**: Community-driven arbitration ensures unbiased dispute handling
- **Quick Resolution**: 10-day maximum resolution time
- **Transparency**: All votes and reasoning recorded on-chain
- **Protection**: Both renters and owners protected from fraudulent claims

### For Arbitrators
- **Earn Reputation**: Build credibility through fair arbitration decisions
- **Community Participation**: Contribute to platform governance and fairness
- **Stake Security**: Economic incentives ensure responsible voting behavior

### For the Platform
- **Reduced Manual Intervention**: Automated dispute resolution
- **Community Trust**: Decentralized arbitration builds user confidence
- **Scalability**: System scales with community growth
- **Transparency**: All dispute processes publicly auditable

## Technical Implementation

### Smart Contract Architecture
- **Modular Design**: Separate systems for rentals, disputes, and arbitration
- **Gas Optimization**: Efficient data structures and minimal on-chain storage
- **Error Handling**: Comprehensive validation and error reporting
- **Upgradeability**: Extensible design for future enhancements
- **Bulk Processing**: Efficient fold operations with proper error propagation
- **Emergency Controls**: Built-in circuit breaker for security

### Emergency Pause Implementation
- **State Variable**: Single boolean flag controls pause state
- **Function Guards**: All critical functions check pause state
- **Owner Only**: Pause/unpause restricted to contract owner
- **Read Functions**: Query functions always available
- **Critical Path**: Return and dispute functions remain operational
- **Atomic State**: Pause state changes take effect immediately

### Bulk Operations Flow
1. Validate batch size (1-10 items)
2. Check contract pause state
3. Iterate through items using fold
4. Validate each item individually
5. Execute operations atomically
6. Return success with list of IDs or error on any failure

### Dispute Resolution Flow
1. Dispute creation locks rental funds in escrow
2. Arbitrators have 10 days to review and vote
3. Minimum 3 votes required for resolution
4. Majority vote determines outcome
5. Automatic fund distribution based on result
6. Arbitrator statistics updated for reputation tracking

## Testing Recommendations

### Emergency Pause Testing
- Verify only owner can pause/unpause
- Test all functions are blocked when paused
- Verify critical functions (return, disputes) still work
- Test pause state persists correctly
- Verify unpause restores full functionality
- Test unauthorized pause attempts fail

### Bulk Operations Testing
- Test with 1, 5, and 10 items (boundary conditions)
- Verify empty batch rejection
- Test oversized batch rejection (>10 items)
- Validate atomic behavior (all-or-nothing)
- Test partial failure scenarios
- Compare gas costs vs individual operations
- Test with invalid data in batch
- Verify proper error propagation
- Test bulk operations respect pause state

### Standard Testing
- Happy path: Complete rental lifecycle
- Edge cases: Boundary values, empty strings
- Security: Unauthorized access attempts
- Dispute resolution: Full arbitration cycle
- Gas optimization: Function efficiency
- Error handling: All error codes triggered

## Future Enhancements

- **Advanced Reputation Algorithms**: More sophisticated scoring based on dispute outcomes
- **Arbitrator Rewards**: Token incentives for active and fair arbitrators  
- **Multi-tier Disputes**: Different arbitration levels based on dispute value
- **Appeal Process**: Secondary arbitration for disputed resolutions
- **Insurance Integration**: Optional insurance coverage for high-value items
- **Advanced Bulk Operations**: Support for larger batches with pagination
- **Batch Return Operations**: Return multiple items simultaneously
- **Scheduled Rentals**: Pre-book items for future dates
- **Bulk Rating System**: Rate multiple rentals in one transaction
- **Analytics Dashboard**: Usage statistics for bulk operations
- **Automated Pause Triggers**: Smart pause based on suspicious activity detection
- **Multi-sig Admin**: Multiple owners for critical functions
- **Gradual Resume**: Phased unpause for high-traffic periods

## Contributing

We welcome contributions! Please ensure:
- All code passes `clarinet check` without errors or warnings
- Proper input validation on all functions
- No unchecked data warnings
- Comprehensive error handling
- Updated documentation for new features
- Test coverage for new functionality
- Security considerations documented
- Emergency pause integration for new critical functions

## Change Log

### Version 2.1.0 - Emergency Pause System
- Added `pause-contract` and `unpause-contract` functions for emergency control
- Added `is-contract-paused` read-only function
- Integrated pause checks into all critical marketplace operations
- New error code `ERR_CONTRACT_PAUSED` (u123)
- Maintained operational capability for returns and disputes during pause
- Enhanced security and platform management capabilities

### Version 2.0.0 - Bulk Operations Update
- Added `bulk-list-items` for efficient multi-item listing
- Added `bulk-rent-items` for batch rental operations
- Implemented MAX_BULK_ITEMS constant (10 items max)
- Added error codes for batch operations (u121, u122)
- Optimized gas costs through batching
- Enhanced user experience for power users

---

**Version**: 2.1.0 (Emergency Pause System)  
**License**: MIT  
**Blockchain**: Stacks  
**Language**: Clarity