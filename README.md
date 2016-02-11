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
    [{ 'accountNumber' => 'brkAcct1',
       'name' => 'Individual Account (XX878977484)' }],
           'longMessages' => nil,
           'shortMessage' => 'Credential Successfully Validated',
           'status' => 'SUCCESS',
           'token' => 'ce15f0eb7a9a473eb40687cdf3150479' },
  status: 200,
  payload:   { type: 'success',
               token: 'ce15f0eb7a9a473eb40687cdf3150479',
               accounts:     [{ 'accountNumber' => 'brkAcct1',
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
  messages: [nil] }
```

Successful response requesting image style security question

```
{ raw:   { 'challengeImage' => 'Base 64 Encoded Image',
           'errorFields' => nil,
           'informationLongMessage' => nil,
           'informationShortMessage' => 'Send',
           'informationType' => 'SECURITY_QUESTION',
           'longMessages' => nil,
           'shortMessage' => nil,
           'status' => 'INFORMATION_NEEDED',
           'token' => 'e106022c16d64534873cd1dcffa65d20' },
  status: 200,
  payload:   { type: 'verify',
               challenge: 'image',
               token: 'e106022c16d64534873cd1dcffa65d20',
               data: { encoded: 'Base 64 Encoded Image' } },
  messages: [nil] }
```

Login failure will raise a `TradeIt::Errors::LoginException` with the following attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Login',
  messages: ['Check your username and password and try again.'] }
```
