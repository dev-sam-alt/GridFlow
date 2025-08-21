# GridFlow Certification Protocol

A comprehensive blockchain-based certification system for renewable energy providers built on the Stacks blockchain using Clarity smart contracts.

## Overview

GridFlow Certification Protocol provides a robust, transparent, and automated system for certifying, monitoring, and managing renewable energy providers. The protocol ensures energy grid reliability through tiered certification levels, performance tracking, and compliance monitoring.

## Features

### Multi-Tier Certification System
- **Provisional**: Entry-level certification for new providers
- **Certified**: Standard operational certification
- **Premium**: High-performance provider status
- **Elite**: Top-tier providers with exceptional metrics

### Performance Monitoring
- Real-time energy production tracking
- Reliability rating assessment
- Carbon offset calculations
- Grid stability scoring

### Compliance Management
- Automated expiry tracking
- Renewal notifications
- Suspension capabilities
- Audit trail maintenance

### Regional Coverage
- Multi-region support
- Capacity threshold enforcement
- Technology type classification

## Smart Contract Architecture

### Core Components

#### `energy-provider-registry`
Central registry storing comprehensive provider information including:
- Provider identification and metadata
- Certification status and tier level
- Operational parameters and capacity
- Compliance scores and audit history

#### `provider-performance-metrics`
Performance tracking system monitoring:
- Total energy production
- Reliability ratings
- Carbon offset contributions
- Grid stability impact

#### `certification-tiers`
Hierarchical certification levels with numeric ranking system.

## Usage

### For Certification Authorities

#### Register New Provider
```clarity
(register-energy-provider 
    provider-address 
    "Solar Solutions Inc" 
    "California" 
    u2500 
    "Solar Photovoltaic")
```

#### Upgrade Certification
```clarity
(upgrade-certification-tier provider-address "PREMIUM")
```

#### Update Performance Metrics
```clarity
(update-performance-metrics 
    provider-address 
    u1500  ;; energy-produced
    u95    ;; reliability-rating
    u2000  ;; carbon-offset
    u88)   ;; grid-stability-score
```

### For Public Access

#### Check Certification Status
```clarity
(is-provider-certified provider-address)
```

#### Get Provider Details
```clarity
(get-provider-details provider-address)
```

#### Check Renewal Status
```clarity
(needs-renewal-soon provider-address)
```

## Installation & Deployment

### Prerequisites
- Stacks CLI
- Node.js 16+
- Clarity development environment

### Deployment Steps

1. **Clone Repository**
```bash
git clone https://github.com/dev-sam-alt/GridFlow.git
cd GridFlow
```

2. **Install Dependencies**
```bash
npm install
```

3. **Deploy to Testnet**
```bash
clarinet deployments generate --devnet
clarinet deployments apply -p deployments/default.devnet-plan.yaml
```

4. **Verify Deployment**
```bash
clarinet console
```

## Configuration

### Certification Parameters
- **Validity Period**: 52,560 blocks (~1 year)
- **Minimum Capacity**: 1,000 MW
- **Certification Authority**: Configurable principal

### Error Codes
- `u100`: Unauthorized access
- `u101`: Provider already exists
- `u102`: Provider not found
- `u103`: Invalid parameters
- `u104`: Certification expired

## Testing

Run comprehensive test suite:
```bash
clarinet test
```

Test specific functionality:
```bash
clarinet test --filter "certification-upgrade"
```

## Security Considerations

### Access Control
- Only certification authority can register providers
- Administrative functions require proper authorization
- Read-only functions are publicly accessible

### Data Integrity
- Immutable registration records
- Transparent audit trails
- Cryptographic verification

## Governance

### Authority Transfer
The certification authority can be transferred through the `transfer-certification-authority` function, enabling decentralized governance models.

### Parameter Updates
System parameters can be updated by the current authority to adapt to changing grid requirements.

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Submit pull request

## Roadmap

- [ ] Integration with IoT monitoring devices
- [ ] Automated compliance checking
- [ ] Cross-chain compatibility
- [ ] Advanced analytics dashboard
- [ ] Machine learning performance predictions