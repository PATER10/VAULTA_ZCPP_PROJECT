# VAULTA - Banking Desktop Application

VAULTA is a student project created to learn and develop practical C++ programming skills.  
The goal of the project was to build a desktop banking application with a modern QML interface, PostgreSQL database integration, object-oriented backend logic, authentication, account management, transfers, currency exchange, transaction history, analytics, ATM operations, and a simple administrator back-office panel.

> This application was created for educational purposes and is not intended to be used as a real banking system.

## Screenshots

Add screenshots of the application here to present the UI and the most important workflows.

### Login

![Login screen](docs/screenshots/login.png)

### User Dashboard

![User dashboard](docs/screenshots/dashboard.png)

### Accounts And Currency Exchange

![Accounts view](docs/screenshots/accounts.png)

### Transaction History

![Transactions view](docs/screenshots/transactions.png)

### Financial Analytics

![Analytics view](docs/screenshots/analytics.png)

### Admin Panel

![Admin dashboard](docs/screenshots/admin-dashboard.png)

## Main Features

- User registration and login system.
- Password and PIN hashing using bcrypt.
- PostgreSQL database integration.
- Support for multiple accounts assigned to one user.
- Standard PLN accounts and currency accounts, for example EUR.
- Active account selection shared across the application.
- Domestic transfers between accounts.
- Transfer protection for accounts with different currencies.
- Currency exchange between PLN and EUR accounts.
- EUR exchange rates fetched from the public NBP API.
- Fallback exchange rates when the external API is unavailable.
- Transaction history with filtering and sorting.
- ATM-like deposit and withdrawal flow.
- Financial analytics dashboard with calculated statistics and charts.
- Administrator dashboard for user management.
- User activation/deactivation.
- Admin password reset functionality.
- User deletion with related account/card/transaction cleanup.

## Technologies Used

- **C++** - core application logic.
- **Qt 6** - application framework.
- **QML / Qt Quick** - declarative user interface.
- **PostgreSQL** - relational database.
- **Qt SQL** - database communication.
- **Qt Network** - external API requests.
- **bcrypt** - password and PIN hashing.
- **NBP API** - EUR exchange rate data.

## Object-Oriented Design

The project uses an object-oriented approach in the C++ backend. The domain logic is split into dedicated classes responsible for separate parts of the application.

Examples of the main classes:

- `User` - represents an authenticated user and stores user-related data.
- `Account` - base class for bank accounts.
- `StandardAccount` - PLN account implementation.
- `CurrencyAccount` - foreign currency account implementation.
- `Card` - card data and card number generation.
- `Transaction` - transaction representation exposed to QML.
- `AuthManager` - registration, login and current user loading.
- `BankManager` - transfers, deposits, withdrawals, currency exchange and transaction loading.
- `AdminManager` - administrator operations for managing users.
- `AppController` - central bridge exposing backend managers to QML.

This structure separates UI code from business logic and makes the application easier to extend with new account types, transaction types, or administrative features.

## Interesting Parts Of The Project

### Multi-account user model

The application supports a one-to-many relationship between a user and accounts. A user can have a main PLN account and additional currency accounts. The currently active account affects account views, transfers, transaction history, and analytics.

### Currency exchange

The app supports currency exchange between PLN and EUR accounts. Exchange rates are fetched from the NBP API:

```text
https://api.nbp.pl/api/exchangerates/rates/c/eur/?format=json
```

If the API is unavailable, the application falls back to predefined rates so the feature can still work offline or during network failure.

### Transaction history

Transactions are stored in PostgreSQL and displayed in QML. The history supports multiple operation types, including:

- transfers,
- deposits,
- withdrawals,
- currency exchange.

The interface distinguishes incoming and outgoing operations and displays exchange-related values when currency conversion is involved.

### Financial analytics

The analytics tab calculates statistics based on the selected account and selected filters. It includes values such as maximum expense, minimum expense, total expenses, total income, and charts over time.

### Admin back-office

The project also includes a simple administrator panel. Admin users can:

- view users,
- edit user profile data,
- activate or deactivate accounts,
- reset user passwords,
- delete users.

This part demonstrates a separation between regular user functionality and administrative functionality.

## Database Overview

The application uses PostgreSQL with tables such as:

- `user` - stores users, hashed passwords, roles and account status.
- `account` - stores user accounts, balances, currencies and account types.
- `card` - stores cards assigned to accounts.
- `transaction` - stores transaction history.

The database supports a one-to-many relation between users and accounts.

## Example User Roles

The application distinguishes between regular users and administrators using the `role` column in the `user` table.

Example roles:

```text
user
admin
```

After login, the application redirects users to the correct dashboard depending on their role.

## Project Structure

```text
VAULTA_ZCPP_PROJECT/
├── VAULTA_ZCPP_PROJECT/
│   ├── *.cpp / *.h          # C++ backend classes
│   ├── *.qml                # QML views
│   ├── images/              # UI assets
│   ├── Translations/        # translation files
│   └── qml.qrc              # Qt resource file
├── VAULTA_ZCPP_PROJECT.sln  # Visual Studio solution
└── README.md
```

## What I Learned

During development of this project I practiced:

- designing C++ classes using OOP principles,
- connecting Qt applications with PostgreSQL,
- exposing C++ objects and methods to QML,
- building interactive desktop interfaces with QML,
- working with authentication and hashed credentials,
- handling multiple related database entities,
- implementing transactions and financial operations,
- consuming external API data,
- designing role-based application navigation,
- debugging UI and backend logic in a larger Qt project.

## Future Improvements

Possible future improvements:

- better validation and error messages,
- more currencies,
- better API abstraction for exchange rates,
- database migrations,
- unit tests for backend logic,
- improved responsive layouts,
- export of transaction history,
- more advanced analytics charts,
- improved admin audit logs.

## Author

Student project created as part of learning advanced C++ programming, Qt/QML application development, database integration, and software architecture.

