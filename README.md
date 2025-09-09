# StyleShare 

A decentralized fashion rental marketplace built on Stacks blockchain, enabling peer-to-peer fashion item rentals with built-in escrow, reputation systems, and community-driven dispute resolution.

## Overview

StyleShare revolutionizes fashion accessibility by creating a trustless marketplace where users can rent and lend high-quality fashion items. The platform uses smart contracts to handle payments, security deposits, reputation tracking, and dispute resolution automatically through a decentralized arbitration system.

## Features

- **Fashion Item Listing**: Users can list their fashion items with detailed descriptions, pricing, and availability
- **Secure Rental System**: Automated escrow system holds payments and security deposits until items are returned
- **Reputation System**: Built-in rating system for items and users to build trust in the marketplace
- **Dispute Resolution System**: Multi-signature arbitration system for rental conflicts with community-voted arbitrators
- **Multi-Category Support**: Supports various fashion categories with size specifications
- **Flexible Duration**: Rental periods from 1 day up to 365 days
- **Platform Fee Structure**: Transparent 2.5% platform fee on successful rentals

## Smart Contract Functions

### Public Functions

**Core Marketplace Functions:**
- `list-fashion-item`: List a new fashion item for rent
- `rent-item`: Rent an available fashion item
- `return-item`: Return a rented item and complete the transaction
- `rate-rental`: Rate a completed rental experience
- `update-item-availability`: Toggle item availability

**Dispute Resolution Functions:**
- `register-arbitrator`: Register as a community arbitrator with stake
- `create-dispute`: Create a dispute for a rental conflict
- `vote-on-dispute`: Vote on dispute resolution (arbitrators only)
- `resolve-dispute`: Execute dispute resolution based on community votes
- `deactivate-arbitrator`: Deactivate arbitrator status and retrieve stake

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

1. Deploy the contract to Stacks testnet/mainnet
2. List your fashion items using `list-fashion-item`
3. Browse available items and rent using `rent-item`
4. Return items and rate experiences to build reputation
5. Register as an arbitrator to participate in dispute resolution
6. Create disputes when rental conflicts arise

## Security Features

- Input validation on all parameters
- Proper error handling with descriptive error codes
- Escrow system prevents payment disputes
- Security deposits protect item owners
- Reputation system builds trust over time
- Staked arbitration system ensures fair dispute resolution
- Time-locked voting periods prevent manipulation

## Error Codes

**Core System:**
- `u100`: Unauthorized access
- `u101`: Item not found
- `u102`: Item not available
- `u103`: Insufficient payment
- `u104`: Rental not found
- `u105`: Rental already returned
- `u106`: Invalid duration
- `u107`: Invalid price
- `u108`: Self-rental attempt
- `u109`: Rental still active
- `u110`: Invalid rating

**Dispute Resolution:**
- `u111`: Dispute not found
- `u112`: Dispute already exists
- `u113`: Dispute already resolved
- `u114`: Not an arbitrator
- `u115`: Already voted
- `u116`: Invalid vote
- `u117`: Voting period ended
- `u118`: Insufficient stake
- `u119`: Already an arbitrator
- `u120`: Arbitrator not found

## Platform Economics

- **Platform Fee**: 2.5% of rental cost
- **Security Deposits**: Set by item owners
- **Payment Flow**: Automatic distribution upon item return or dispute resolution
- **Rating System**: 1-5 star ratings for quality assurance
- **Arbitrator Staking**: Minimum 1 STX stake required for dispute resolution participation
- **Dispute Resolution**: Community-driven with economic incentives for fair arbitration

## Benefits of Dispute Resolution System

### For Users
- **Fair Resolution**: Community-driven arbitration ensures unbiased dispute handling
- **Quick Resolution**: 10-day maximum resolution time
- **Transparency**: All votes and reasoning are recorded on-chain
- **Protection**: Both renters and owners are protected from fraudulent claims

### For Arbitrators
- **Earn Reputation**: Build credibility through fair arbitration decisions
- **Community Participation**: Contribute to platform governance and fairness
- **Stake Security**: Economic incentives ensure responsible voting behavior

### For the Platform
- **Reduced Manual Intervention**: Automated dispute resolution
- **Community Trust**: Decentralized arbitration builds user confidence
- **Scalability**: System scales with community growth
- **Transparency**: All dispute processes are publicly auditable

## Technical Implementation

### Smart Contract Architecture
- **Modular Design**: Separate systems for rentals, disputes, and arbitration
- **Gas Optimization**: Efficient data structures and minimal on-chain storage
- **Error Handling**: Comprehensive validation and error reporting
- **Upgradeability**: Extensible design for future enhancements

### Dispute Resolution Flow
1. Dispute creation locks rental funds in escrow
2. Arbitrators have 10 days to review and vote
3. Minimum 3 votes required for resolution
4. Majority vote determines outcome
5. Automatic fund distribution based on result
6. Arbitrator statistics updated for reputation tracking

## Future Enhancements

- **Advanced Reputation Algorithms**: More sophisticated scoring based on dispute outcomes
- **Arbitrator Rewards**: Token incentives for active and fair arbitrators  
- **Multi-tier Disputes**: Different arbitration levels based on dispute value
- **Appeal Process**: Secondary arbitration for disputed resolutions
- **Insurance Integration**: Optional insurance coverage for high-value items