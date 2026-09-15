# Wheelhouse

Wheelhouse is a web application for a bicycle repair shop.

The project aims to help the workshop keep track of customers, bikes, repairs, services, repair statuses, and historical prices, while also providing visitors with access to the current service price list.

## Requirements

- Ruby 3.4.10
- Rails 8.1.3.1
- Node.js 22.23.2
- PostgreSQL
- Yarn

## Setup

Clone the repository:

```bash
git clone https://github.com/Julf3r/webtech-wheelhouse.git
cd webtech-wheelhouse
```

Install the dependancies:

```bash
bundle install
yarn install
```

Create the development database:

```bash
bin/rails db:create
```

Start the application:

```bash
bin/dev
```
It will be available at `http://localhost:3000`

## Documentation

- [User Stories](docs/user-stories.md)
- [Domain Model](docs/domain-model.md)
- [Decisions](docs/decisions.md)
- [Wireframes](docs/wireframes.md)

## Authors

- Julián Rodríguez