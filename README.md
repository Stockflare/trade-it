# TradeIt

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trade_it', github: 'stockflare/trade-it', tag: '0.1.0'
```

## Usage

This Gem wraps all interactions with The [TradeIt](https://www.trade.it/documentation) API into a format that is convenient for our own internal APIs.

Once installed all TradeIt actions are objects within the `TradeIt` module.  Each object is initialized with the parameters required for the TradeIt call and has one `call` method to execute the communications with TradeIt.  All objects return the result of the TradeIt interaction in a `response` attribute that supports `to_h`

It is expected that most Stockflare use cases will inly use the `response.payload` as this is a parsed version of the TradeIt response suitable for Stockflare's use.

All Error cases are handled by raising a subclass of `TradeIt::Errors::TradeItException`, this object exposes a number of attributes that can you can `to_h` to the consumer.

### Environment Variables

Two variables need to be set

```
TRADEIT_BASE_URI=https://ems.qa.tradingticket.com/api/v1
TRADEIT_API_KEY=xxxxxxxx

```

### Brokers

We current support the following broker symbols
```
{
  td: 'TD',
  etrade: 'Etrade',
  scottrade: 'Scottrade',
  fidelity: 'Fidelity',
  schwab: 'Schwab',
  trade_station: 'TradeStation',
  robinhood: 'Robinhood',
  options_house: 'OptionsHouse',
  ib: 'IB',
  tradier: 'Tradier',
  dummy: 'Dummy'
}
```

### TradeIt::User::Login

example call:

```
TradeIt::User::Login.new(
  username: username,
  password: password,
  broker: broker
).call.response
```

Successful response without security question:

```
{ raw:   { 'accounts' =>
    [{ 'account_number' => 'brkAcct1',
       'name' => 'Individual Account (XX878977484)' }],
           'longMessages' => nil,
           'shortMessage' => 'Credential Successfully Validated',
           'status' => 'SUCCESS',
           'token' => 'ce15f0eb7a9a473eb40687cdf3150479' },
  status: 200,
  payload:   { type: 'success',
               token: 'ce15f0eb7a9a473eb40687cdf3150479',
               accounts:     [{ 'account_number' => 'brkAcct1',
                                'name' => 'Individual Account (XX878977484)' }] },
  messages: ['Credential Successfully Validated'] }
```

Successful response requesting security question

```
{ raw:   { 'challengeImage' => nil,
           'errorFields' => nil,
           'informationLongMessage' => nil,
           'informationShortMessage' => 'Send',
           'informationType' => 'SECURITY_QUESTION',
           'longMessages' => nil,
           'securityQuestion' => "What is your mother's maiden name",
           'securityQuestionOptions' => [],
           'shortMessage' => nil,
           'status' => 'INFORMATION_NEEDED',
           'token' => '7994ee5d86bc4a168d450f268a7cd17b' },
  status: 200,
  payload:   { type: 'verify',
               challenge: 'question',
               token: '7994ee5d86bc4a168d450f268a7cd17b',
               data: { question: "What is your mother's maiden name", answers: [] } },
  messages: [] }
```

Successful response requesting image style security question

The `encoded` image is Base64 encoded

```
{ raw:   { 'challengeImage' =>
    'iVBORw0KGgoAAAANSUhEUgAAAc4AA....',
           'errorFields' => nil,
           'informationLongMessage' => nil,
           'informationShortMessage' => nil,
           'informationType' => 'SECURITY_QUESTION',
           'longMessages' => nil,
           'securityQuestion' =>
    'Two card index numbers are shown in the image below. Please enter them without spaces to proceed.',
           'securityQuestionOptions' => [],
           'shortMessage' => nil,
           'status' => 'INFORMATION_NEEDED',
           'token' => '99db99b421df419c9d02907dff146e2c' },
  status: 200,
  payload:   { type: 'verify',
               challenge: 'image',
               token: '99db99b421df419c9d02907dff146e2c',
               data:     { encoded:       'iVBORw0KGgoAAAANSUhEUgAAAc4AAAA....' } },
  messages: [] }
```

Login failure will raise a `TradeIt::Errors::LoginException` with the following attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Login',
  messages: ['Check your username and password and try again.'] }
```

### TradeIt::User::Verify

Example Call

```
TradeIt::User::Verify.new(
  token: <token from TradeIt::User::Login>,
  answer: answer
).call.response
```

All success responses are identical to `TradeIt::User::Login`

If the user provides a bad answer then the response will be a success asking another question.

A failure will raise a `TradeIt::Errors::LoginException` with the similar attributes:
```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### TradeIt::User::Logout

Example call:
```
TradeIt::User::Logout.new(
  token: <token from previous login>
).call.response
```

Successful logout response

```
{ raw: { 'longMessages' => nil, 'shortMessage' => nil, 'status' => 'SUCCESS', 'token' => '765b7e4056334a27a9b65033b889878e' },
  status: 200,
  payload: { type: 'success', token: '765b7e4056334a27a9b65033b889878e', accounts: nil },
  messages: [] }
```

Failed Logout will raise a `TradeIt::Errors::LogoutException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### TradeIt::User::Refresh

Used to stop a users token from expiring, does not send you a new token

Example Call:

```
TradeIt::User::Refresh.new(
  token: token
).call.response
```

Successful Response:

```
{ raw:   { 'longMessages' => nil,
           'shortMessage' => nil,
           'status' => 'SUCCESS',
           'token' => 'ed34e745c7714be6936370cb1026f33e' },
  status: 200,
  payload:   { type: 'success',
               token: 'ed34e745c7714be6936370cb1026f33e',
               accounts: nil },
  messages: [] }
```

Failed Logout will raise a `TradeIt::Errors::LogoutException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### TradeIt::Position::Get

Example Call

```
TradeIt::Positions::Get.new(
  token: token,
  account_number: account_number
).call.response
```

Successful response:

```
{ raw:   { 'currentPage' => 0,
           'longMessages' => nil,
           'positions' =>
    [{ 'costbasis' => 103.34,
       'holdingType' => 'LONG',
       'lastPrice' => 112.34,
       'quantity' => 1.0,
       'symbol' => 'AAPL',
       'symbolClass' => 'EQUITY_OR_ETF',
       'todayGainLossDollar' => 3.0,
       'todayGainLossPercentage' => 0.34,
       'totalGainLossDollar' => 9.0,
       'totalGainLossPercentage' => 1.2 },
      ...
     ],
           'shortMessage' => 'Position successfully fetched',
           'status' => 'SUCCESS',
           'token' => 'd3e72226aad646cea9e2d6177bd50953',
           'totalPages' => 1 },
  status: 200,
  payload:   { positions:     [{ quantity: 1, price: 103.34, ticker: 'AAPL', instrument_class: 'equity_or_etf', change: 9.0, holding: 'long' },
                               { quantity: -1, price: 103.34, ticker: 'IBM', instrument_class: 'equity_or_etf', change: 9.0, holding: 'short' },
                               { quantity: 1, price: 103.34, ticker: 'GE', instrument_class: 'equity_or_etf', change: 9.0, holding: 'short' },
                               { quantity: 1, price: 103.34, ticker: 'MSFT', instrument_class: 'equity_or_etf', change: 9.0, holding: 'long' }],
               pages: 1,
               page: 0 },
  messages: ['Position successfully fetched'] }
```

Failed Call will raise a `TradeIt::Errors::PositionException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Fetch Your Positions',
  messages:   ['The account foooooobaaarrrr is not valid or not active anymore.'] }
```
