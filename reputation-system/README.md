# ReputationStacks - Blockchain Reputation System

## Features

- STX token staking requirement
- 5-star rating system
- One review per user pair
- Cumulative reputation scoring
- Stake-based participation
- Principal address validation

## Contract Functions

### Read-Only Functions

- `get-stake`: Returns user's staked amount
- `get-reputation`: Returns user's reputation score
- `get-review`: Gets specific review details

### Public Functions

- `stake`: Stake STX tokens
- `unstake`: Withdraw staked tokens
- `submit-review`: Submit rating for a user
- `update-admin`: Update contract admin

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: Unauthorized action
- `ERR-ALREADY-REVIEWED (u101)`: Duplicate review attempt
- `ERR-INSUFFICIENT-STAKE (u102)`: Stake requirement not met
- `ERR-INVALID-RATING (u103)`: Rating exceeds maximum
- `ERR-INVALID-PRINCIPAL (u104)`: Invalid principal address

## Setup

1. Install Clarinet
```bash
curl -sSL https://install.clarinet.sh | sh
```

2. Clone repository
```bash
git clone https://github.com/yourusername/stx-reputation-system.git
cd stx-reputation-system
```

3. Run tests
```bash
clarinet test
```

## Security Measures

- Minimum stake requirement (1000 STX)
- Principal address validation
- Single review per user pair
- Admin access control