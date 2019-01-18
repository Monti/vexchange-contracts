contract Exchange():
    def setup(token_addr: address, owner_addr: address, platform_fee_amount: uint256, swap_fee_amount: uint256, max_platform_fee: uint256, max_swap_fee:uint256) : modifying

NewExchange: event({token: indexed(address), exchange: indexed(address)})

exchangeTemplate: public(address)
tokenCount: public(uint256)
token_to_exchange: address[address]
exchange_to_token: address[address]
id_to_token: address[uint256]
owner : public(address)
default_swap_fee: uint256
default_platform_fee :uint256
default_max_swap_fee: uint256
default_max_platform_fee: uint256


@public
def __init__(template: address):
    assert template != ZERO_ADDRESS
    self.exchangeTemplate = template
    self.owner = msg.sender
    self.default_max_platform_fee = 10000
    self.default_max_swap_fee = 10000
    self.default_platform_fee = 7500
    self.default_swap_fee = 200

@public
def setOwner(_owner: address):
    assert msg.sender == self.owner and _owner != ZERO_ADDRESS
    self.owner = _owner

@public
def setPlatformFee(_default_platform_fee: uint256):
    assert msg.sender == self.owner
    assert _default_platform_fee < self.default_max_platform_fee
    self.default_platform_fee = _default_platform_fee

@public
def setSwapFee(_default_swap_fee: uint256):
    assert msg.sender == self.owner
    assert _default_swap_fee < self.default_max_swap_fee
    self.default_swap_fee = _default_swap_fee

@public
def setMaxPlatformFee(_default_max_platform_fee: uint256):
    assert msg.sender == self.owner
    assert _default_max_platform_fee < self.default_max_platform_fee
    assert _default_max_platform_fee >= self.default_platform_fee
    self.default_max_platform_fee = _default_max_platform_fee

@public
def setMaxSwapFee(_default_max_swap_fee: uint256):
    assert msg.sender == self.owner
    assert _default_max_swap_fee < self.default_max_swap_fee
    assert _default_max_swap_fee >= self.default_swap_fee
    self.default_max_swap_fee = _default_max_swap_fee


@public
def createExchange(token: address) -> address:
    assert token != ZERO_ADDRESS
    assert self.exchangeTemplate != ZERO_ADDRESS
    assert self.token_to_exchange[token] == ZERO_ADDRESS
    exchange: address = create_with_code_of(self.exchangeTemplate)
    Exchange(exchange).setup(token, self.owner, self.default_platform_fee, self.default_swap_fee, self.default_max_platform_fee, self.default_max_swap_fee)
    self.token_to_exchange[token] = exchange
    self.exchange_to_token[exchange] = token
    token_id: uint256 = self.tokenCount + 1
    self.tokenCount = token_id
    self.id_to_token[token_id] = token
    log.NewExchange(token, exchange)
    return exchange

@public
@constant
def getExchange(token: address) -> address:
    return self.token_to_exchange[token]

@public
@constant
def getToken(exchange: address) -> address:
    return self.exchange_to_token[exchange]

@public
@constant
def getTokenWithId(token_id: uint256) -> address:
    return self.id_to_token[token_id]
