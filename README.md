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
bin/rails db:setup
```

Start the application:

```bash
bin/dev
```
It will be available at `http://localhost:3000`


## Lab 10 — Versioned JSON API

Wheelhouse provides a versioned JSON API for public service prices and private accounting operations.

API base URL:

`http://localhost:3000/api/v1`

Full API documentation: [docs/api.md](docs/api.md)

### Requirements

- Ruby and Bundler
- PostgreSQL
- Rails dependencies installed through Bundler
- Node.js and npm if required by the project's asset setup

### Local setup

Clone the repository and enter the project directory:

```bash
git clone https://github.com/Julf3r/webtech-wheelhouse.git
cd webtech-wheelhouse
```

Install Ruby dependencies:

```bash
bundle install
```

Install JavaScript dependencies if the project requires them:

```bash
npm install
```

Make sure PostgreSQL is running and that the database credentials in `config/database.yml` are correctly configured for your local environment.

Create and prepare the database:

```bash
bin/rails db:prepare
```

Optionally load sample data:

```bash
bin/rails db:seed
```

### API token

The API token is stored in Rails encrypted credentials.

To configure it, run:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

Add the following entry:

```yaml
api_token: "YOUR_GENERATED_SECRET_TOKEN"
```

Generate a secure token with:

```bash
bin/rails secret
```

Copy the generated token into the credentials file.

Do not commit `config/master.key` or disclose the token.

A new clone requires access to the appropriate Rails master key to decrypt existing credentials, or a newly configured credentials file and key for that environment.

### Start the application

Run Rails on port 3000:

```bash
bin/rails server -p 3000
```

The API is now available at:

`http://localhost:3000/api/v1`

### Public API request

Retrieve the service price list:

```bash
curl http://localhost:3000/api/v1/services
```

Retrieve one service:

```bash
curl http://localhost:3000/api/v1/services/129
```

Replace `129` with an existing service ID.

### Authenticated API request

Set your token in the terminal without displaying it:

```bash
read -rsp "API token: " API_TOKEN; echo
```

Retrieve repairs:

```bash
curl -H "Authorization: Bearer $API_TOKEN" \
  http://localhost:3000/api/v1/repairs
```

Create a service:

```bash
curl -X POST http://localhost:3000/api/v1/services \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"service":{"name":"Brake adjustment","current_price":"15000.00"}}'
```

### Personal website integration

The service price list is also displayed on my personal website:

https://julf3r.github.io/webtech-lab-01/

The website uses JavaScript `fetch` to request the public service API and dynamically render the results.

The website also allows users to search for an individual service by ID.

For local development, serve the personal website on port 5500:

```bash
python3 -m http.server 5500
```

The Wheelhouse API must be running on port 3000 for the website to retrieve its data.

The published website also uses the local API address, so the API must be accessible from the browser on the computer opening the page.

### Running tests

Run the Rails test suite:

```bash
bin/rails test
```

Verify Rails autoloading:

```bash
bin/rails zeitwerk:check
```

Inspect the API routes:

```bash
bin/rails routes -g api
```


## Documentation

- [User Stories](docs/user-stories.md)
- [Domain Model](docs/domain-model.md)
- [Decisions](docs/decisions.md)
- [Wireframes](docs/wireframes.md)

## Authors

- Julián Rodríguez