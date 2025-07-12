# StyleShare 

A decentralized fashion rental marketplace built on Stacks blockchain, enabling peer-to-peer fashion item rentals with built-in escrow and reputation systems.

## Overview

StyleShare revolutionizes fashion accessibility by creating a trustless marketplace where users can rent and lend high-quality fashion items. The platform uses smart contracts to handle payments, security deposits, and reputation tracking automatically.

## Features

- **Fashion Item Listing**: Users can list their fashion items with detailed descriptions, pricing, and availability
- **Secure Rental System**: Automated escrow system holds payments and security deposits until items are returned
- **Reputation System**: Built-in rating system for items and users to build trust in the marketplace
- **Multi-Category Support**: Supports various fashion categories with size specifications
- **Flexible Duration**: Rental periods from 1 day up to 365 days
- **Platform Fee Structure**: Transparent 2.5% platform fee on successful rentals

## Smart Contract Functions

### Public Functions

- `list-fashion-item`: List a new fashion item for rent
- `rent-item`: Rent an available fashion item
- `return-item`: Return a rented item and complete the transaction
- `rate-rental`: Rate a completed rental experience
- `update-item-availability`: Toggle item availability

### Read-Only Functions

- `get-fashion-item`: Retrieve item details
- `get-rental`: Get rental information
- `get-user-profile`: View user statistics and reputation
- `get-next-item-id`: Current item counter
- `get-next-rental-id`: Current rental counter
- `get-platform-fee-rate`: Current platform fee rate

## Data Structures

### Fashion Items
- Item ID, owner, title, description
- Category, size, daily rate, security deposit
- Availability status, rental history, ratings

### Rentals
- Rental ID, item reference, renter/owner info
- Rental period, costs, return status
- Rating system integration

### User Profiles
- Rental statistics, reputation scores
- Total earnings, transaction history

## Getting Started

1. Deploy the contract to Stacks testnet/mainnet
2. List your fashion items using `list-fashion-item`
3. Browse available items and rent using `rent-item`
4. Return items and rate experiences to build reputation

## Security Features

- Input validation on all parameters
- Proper error handling with descriptive error codes
- Escrow system prevents payment disputes
- Security deposits protect item owners
- Reputation system builds trust over time

## Error Codes

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

## Platform Economics

- **Platform Fee**: 2.5% of rental cost
- **Security Deposits**: Set by item owners
- **Payment Flow**: Automatic distribution upon item return
- **Rating System**: 1-5 star ratings for quality assurance

