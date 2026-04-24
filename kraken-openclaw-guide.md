# Kraken API + OpenClaw Integration Guide
*Comprehensive reference for automated trading assistance*

---

## 1. Kraken API Overview

### Base URLs
| Surface | URL |
|---|---|
| Spot REST | `https://api.kraken.com/0/` |
| Spot WebSocket v2 | `wss://ws.kraken.com/v2` |
| Futures REST (live) | `https://futures.kraken.com/derivatives/api/v3/` |
| Futures REST (demo/testnet) | `https://demo-futures.kraken.com/derivatives/api/v3/` |

### Authentication

Kraken uses **API Key + HMAC-SHA512 signature** for private endpoints. No OAuth.

**How it works:**
1. Generate API key/secret in Kraken account → Security → API
2. Every private request includes:
   - `API-Key` header: your public API key
   - `API-Sign` header: HMAC-SHA512 signature
   - `nonce`: ever-increasing integer (milliseconds timestamp works)

**Signature formula:**
```
message = urlpath + SHA256(nonce + POST_data)
signature = HMAC-SHA512(base64_decode(secret), message)
API-Sign = base64_encode(signature)
```

**API Key Permissions (set at creation time):**
- `Query Funds` — read balances
- `Query Open Orders & Trades` — check orders
- `Query Closed Orders & Trades` — history
- `Create & Modify Orders` — place/amend orders
- `Cancel/Close Orders` — cancel orders
- `Export Data` — trade/ledger export
- `Access WebSockets API` — WebSocket auth token

**Security best practice:** Only grant minimum needed permissions. Never enable `Withdraw` unless absolutely necessary.

---

### Rate Limits (Spot REST)

| Tier | Max Counter | Decay Rate |
|---|---|---|
| Starter | 15 | −0.33/sec |
| Intermediate | 20 | −0.5/sec |
| Pro | 20 | −1/sec |

- Most calls cost **1 counter unit**
- Ledger/trade history calls cost **2 units**
- `AddOrder` / `CancelOrder` have a **separate order rate limiter**
- Error response: `EAPI:Rate limit exceeded`
- Throttle response: `EService:Throttled:[unix_timestamp]`

**Practical rule:** Stay under 1 call/second for safety at Starter tier.

---

### Key Endpoints

#### Public (no auth needed)
| Endpoint | Path | Description |
|---|---|---|
| Server Time | `GET /0/public/Time` | Server time |
| Asset Info | `GET /0/public/Assets` | Available assets |
| Tradable Pairs | `GET /0/public/AssetPairs` | All trading pairs |
| Ticker | `GET /0/public/Ticker?pair=XBTUSD` | Current price/vol |
| OHLC | `GET /0/public/OHLC?pair=XBTUSD&interval=60` | Candles (1-1440 min) |
| Order Book | `GET /0/public/Depth?pair=XBTUSD&count=10` | Bid/ask book |
| Recent Trades | `GET /0/public/Trades?pair=XBTUSD` | Recent trades |

#### Private (auth required)
| Endpoint | Path | Description |
|---|---|---|
| Account Balance | `POST /0/private/Balance` | All asset balances |
| Trade Balance | `POST /0/private/TradeBalance` | Trade account summary |
| Open Orders | `POST /0/private/OpenOrders` | Active orders |
| Closed Orders | `POST /0/private/ClosedOrders` | Order history |
| Add Order | `POST /0/private/AddOrder` | Place order |
| Cancel Order | `POST /0/private/CancelOrder` | Cancel by txid |
| Trade History | `POST /0/private/TradesHistory` | Executed trades |
| Ledgers | `POST /0/private/Ledgers` | Deposits/withdrawals |

---

## 2. Integration Approaches

### A. Direct REST API (raw Python, no dependencies)

Best for: lightweight scripts, full control, minimal deps.

```python
import time, base64, hashlib, hmac, urllib.request, urllib.parse, json

API_KEY = "your_api_key"
API_SECRET = "your_base64_secret"
BASE_URL = "https://api.kraken.com"

def get_signature(urlpath: str, data: dict, secret: str) -> str:
    nonce = str(data["nonce"])
    encoded = (nonce + urllib.parse.urlencode(data)).encode("utf-8")
    message = urlpath.encode("utf-8") + hashlib.sha256(encoded).digest()
    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    return base64.b64encode(mac.digest()).decode()

def kraken_private(endpoint: str, params: dict = {}) -> dict:
    params["nonce"] = str(int(time.time() * 1000))
    urlpath = f"/0/private/{endpoint}"
    sig = get_signature(urlpath, params, API_SECRET)
    headers = {"API-Key": API_KEY, "API-Sign": sig,
               "Content-Type": "application/x-www-form-urlencoded"}
    data = urllib.parse.urlencode(params).encode("utf-8")
    req = urllib.request.Request(BASE_URL + urlpath, data=data, headers=headers)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())

def kraken_public(endpoint: str, params: dict = {}) -> dict:
    qs = urllib.parse.urlencode(params)
    url = f"{BASE_URL}/0/public/{endpoint}?{qs}"
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read())
```

### B. python-kraken-sdk (official-quality community SDK)

Best for: full-featured bot, WebSocket support, async.

```bash
pip install python-kraken-sdk
```

```python
from kraken.spot import Market, User, Trade

# Public market data
market = Market()
ticker = market.get_ticker(pair="XBTUSD")
ohlc = market.get_ohlc(pair="XBTUSD", interval=60)

# Private (auth required)
user = User(key="YOUR_KEY", secret="YOUR_SECRET")
balances = user.get_balances()

trader = Trade(key="YOUR_KEY", secret="YOUR_SECRET")
order = trader.create_order(
    ordertype="limit",
    side="buy",
    pair="XBTUSD",
    price="40000",
    volume="0.001"
)
```

**Futures testnet support built-in:**
```python
from kraken.futures import User as FuturesUser
user = FuturesUser(key="DEMO_KEY", secret="DEMO_SECRET", 
                   url="https://demo-futures.kraken.com")
```

### C. CCXT (Multi-Exchange Framework)

Best for: portability — same code works on Binance, Coinbase, etc.

```bash
pip install ccxt
```

```python
import ccxt

exchange = ccxt.kraken({
    "apiKey": "your_key",
    "secret": "your_secret",
})

# Standardized across all exchanges:
balance = exchange.fetch_balance()
ticker = exchange.fetch_ticker("BTC/USD")
order = exchange.create_limit_buy_order("BTC/USD", 0.001, 40000)
orders = exchange.fetch_open_orders("BTC/USD")
```

### D. Polling vs WebSocket

| Strategy | Polling (REST) | WebSocket |
|---|---|---|
| Latency | ~1-5s intervals | Real-time (<100ms) |
| Rate limit impact | Uses counter | Separate limit |
| Complexity | Simple | Moderate |
| Best for | DCA, rebalancing | Order book, market making |
| OpenClaw use | ✅ Recommended to start | For advanced later |

**Polling recommendation for OpenClaw:** Use 5-60 second intervals for most strategies. Avoid sub-second polling.

### E. Sandbox / Testnet Availability

| Product | Sandbox Available |
|---|---|
| **Spot (REST/WS)** | ❌ No sandbox exists |
| **Futures (REST/WS)** | ✅ `demo-futures.kraken.com` |

**Spot workaround options:**
1. Use **very small real amounts** (e.g. $5-10 worth of trades)
2. **Paper trading layer** in your code (simulate fills without sending orders)
3. Use Futures demo for logic testing, then port to Spot

---

## 3. OpenClaw Implementation Options

### Option A: Custom Skill (`~/.openclaw/skills/kraken/`)

Create a skill that teaches OpenClaw how to use your Kraken helper script:

```
~/.openclaw/skills/kraken/
├── SKILL.md          ← skill instructions + description
├── scripts/
│   ├── kraken_client.py   ← core API client
│   ├── balance.py         ← get balances
│   ├── place_order.py     ← order placement (with safeguards)
│   └── market_data.py     ← fetch ticker/OHLC
└── references/
    └── pairs.md           ← common pair names reference
```

**SKILL.md structure:**
```markdown
---
name: kraken
description: Kraken exchange trading — check balances, place orders, get market data, run DCA strategies. Use when asked about crypto portfolio, prices, or trading on Kraken.
---

# Kraken Trading Skill

## Setup
API credentials stored in ~/.openclaw/secrets/kraken.env
Load with: source ~/.openclaw/secrets/kraken.env

## Available Scripts
- balance.py — show all balances
- place_order.py --pair XBTUSD --side buy --type limit --price 40000 --vol 0.001
- market_data.py --pair XBTUSD

## Safety Rules
- Never place orders > $100 without explicit confirmation
- Always confirm order details before execution
- Log every trade to ~/.openclaw/workspace/trade-log.jsonl
```

### Option B: Dedicated Trading Sub-Agent

Spawn a sub-agent for intensive analysis or execution tasks:

```
Main Agent
├── Receives user request ("DCA $50 into BTC")
├── Spawns "market-analysis" sub-agent
│   └── Fetches OHLC, computes moving averages, returns signal
├── Reviews signal (main agent decides)
└── Spawns "order-execution" sub-agent (if approved)
    └── Places order, monitors fill, reports back
```

**Separation of concerns:**
- **Main agent**: Strategy decisions, user communication, risk checks
- **Analysis sub-agent**: Market data, indicators, signals (READ-ONLY)
- **Execution sub-agent**: Order placement, status monitoring (WRITE — requires human approval gate)

### Option C: Agent Architecture for Automated DCA

```
Cron job (daily) → OpenClaw session
    → Read HEARTBEAT.md for DCA config
    → Fetch current BTC price
    → Check if conditions met (price in range, time elapsed)
    → Calculate order size
    → ASK USER FOR APPROVAL (telegram message)
    → Wait for confirm/deny
    → Execute or skip
    → Log result
```

---

## 4. Example Use Cases

### DCA Automation

```python
# dca_bot.py — Run via cron or heartbeat
import json
from datetime import datetime
from kraken_client import kraken_private, kraken_public

DCA_CONFIG = {
    "pair": "XBTUSD",
    "weekly_amount_usd": 50,
    "max_price": 80000,  # Don't buy above this
    "min_order_usd": 10,  # Minimum per order
}

def run_dca():
    # Get current price
    ticker = kraken_public("Ticker", {"pair": DCA_CONFIG["pair"]})
    price = float(ticker["result"]["XXBTZUSD"]["c"][0])
    
    if price > DCA_CONFIG["max_price"]:
        return f"SKIP: Price {price} above max {DCA_CONFIG['max_price']}"
    
    # Calculate volume
    volume = round(DCA_CONFIG["weekly_amount_usd"] / price, 6)
    
    # Place market order
    result = kraken_private("AddOrder", {
        "ordertype": "market",
        "type": "buy",
        "pair": DCA_CONFIG["pair"],
        "volume": str(volume),
    })
    
    # Log trade
    log_entry = {
        "time": datetime.utcnow().isoformat(),
        "action": "DCA_BUY",
        "pair": DCA_CONFIG["pair"],
        "price": price,
        "volume": volume,
        "result": result,
    }
    with open("trade-log.jsonl", "a") as f:
        f.write(json.dumps(log_entry) + "\n")
    
    return log_entry
```

### Portfolio Rebalancing

```python
def check_rebalance():
    TARGET = {"XBT": 0.60, "ETH": 0.30, "USD": 0.10}
    REBALANCE_THRESHOLD = 0.05  # 5% drift triggers rebalance
    
    balances = kraken_private("Balance")["result"]
    prices = {}  # fetch from Ticker endpoint
    
    # Calculate current allocations
    total_value_usd = sum(
        float(balances.get(asset, 0)) * prices.get(asset, 1)
        for asset in TARGET
    )
    current = {
        asset: (float(balances.get(asset, 0)) * prices.get(asset, 1)) / total_value_usd
        for asset in TARGET
    }
    
    # Identify drifted assets
    drifted = {
        asset: current[asset] - TARGET[asset]
        for asset in TARGET
        if abs(current[asset] - TARGET[asset]) > REBALANCE_THRESHOLD
    }
    return drifted  # Return for agent to review before acting
```

### Stop-Loss Manager

```python
def check_stop_losses(positions: list):
    """Check existing positions against stop-loss levels."""
    ticker = kraken_public("Ticker", {
        "pair": ",".join(p["pair"] for p in positions)
    })
    
    alerts = []
    for pos in positions:
        current_price = float(ticker["result"][pos["pair_name"]]["c"][0])
        if current_price <= pos["stop_loss"]:
            alerts.append({
                "pair": pos["pair"],
                "current": current_price,
                "stop": pos["stop_loss"],
                "action_needed": "SELL",
            })
    return alerts  # Agent decides/confirms before executing
```

### Grid Trading Logic

```python
def setup_grid(pair: str, low: float, high: float, grids: int, total_usd: float):
    """Calculate grid orders — returns order list for review before placing."""
    step = (high - low) / grids
    order_size_usd = total_usd / grids
    
    orders = []
    for i in range(grids):
        price = low + (i * step)
        volume = round(order_size_usd / price, 6)
        orders.append({
            "type": "buy" if price < (low + high) / 2 else "sell",
            "price": round(price, 2),
            "volume": volume,
            "pair": pair,
        })
    
    return orders  # Agent presents to user for approval before batch placement
```

---

## 5. Security & Risk Considerations

### API Key Storage

**Recommended approach (environment variables + .env file):**
```bash
# ~/.openclaw/secrets/kraken.env (chmod 600!)
export KRAKEN_API_KEY="your_public_key_here"
export KRAKEN_API_SECRET="your_base64_secret_here"
```

```python
import os
API_KEY = os.environ["KRAKEN_API_KEY"]
API_SECRET = os.environ["KRAKEN_API_SECRET"]
```

**Checklist:**
- ✅ Store in `~/.openclaw/secrets/` (not workspace root)
- ✅ `chmod 600` the secrets file
- ✅ Add `secrets/` to `.gitignore` — **never commit keys**
- ✅ Use separate API keys per bot/strategy
- ✅ Enable IP whitelisting in Kraken account settings
- ✅ Set key permissions to minimum needed (no Withdraw!)
- ❌ Never hardcode keys in scripts
- ❌ Never log API keys in output

### Rate Limiting in Code

```python
import time

class RateLimitedKraken:
    def __init__(self, calls_per_second=0.5):  # Conservative: 1 call per 2s
        self.min_interval = 1.0 / calls_per_second
        self.last_call = 0
    
    def call(self, fn, *args, **kwargs):
        elapsed = time.time() - self.last_call
        if elapsed < self.min_interval:
            time.sleep(self.min_interval - elapsed)
        self.last_call = time.time()
        
        result = fn(*args, **kwargs)
        
        # Handle rate limit errors
        if "error" in result and result["error"]:
            if "EAPI:Rate limit exceeded" in result["error"]:
                time.sleep(5)  # Back off
                return self.call(fn, *args, **kwargs)  # Retry once
        return result
```

### Trade Size Safety Limits

```python
SAFETY_CONFIG = {
    "max_single_order_usd": 100,       # Per order cap
    "max_daily_usd": 500,              # Daily total cap
    "require_confirmation_above": 50,  # Ask human above this
    "emergency_stop": False,           # Set True to halt all trading
}

def safe_place_order(pair, side, vol, price=None):
    if SAFETY_CONFIG["emergency_stop"]:
        raise Exception("EMERGENCY STOP ACTIVE — trading halted")
    
    # Check size limit
    approx_usd = vol * (price or get_current_price(pair))
    if approx_usd > SAFETY_CONFIG["max_single_order_usd"]:
        raise Exception(f"Order size ${approx_usd:.2f} exceeds limit")
    
    return kraken_private("AddOrder", {...})
```

### Audit Logging

```python
import json
from datetime import datetime

def log_trade(action: str, details: dict, result: dict):
    entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "action": action,
        "details": details,
        "result": result,
        "success": not bool(result.get("error")),
    }
    with open("~/.openclaw/workspace/trade-log.jsonl", "a") as f:
        f.write(json.dumps(entry) + "\n")
```

### Emergency Stop

```bash
# ~/.openclaw/workspace/EMERGENCY_STOP
# If this file exists, all trading halts immediately
```

```python
import os

def check_emergency_stop():
    if os.path.exists("EMERGENCY_STOP"):
        raise SystemExit("🛑 EMERGENCY_STOP file detected. Trading halted.")
```

---

## 6. Code Examples

### Get Account Balance

```python
# Python (raw)
def get_balance():
    result = kraken_private("Balance")
    if result["error"]:
        return f"Error: {result['error']}"
    balances = {k: v for k, v in result["result"].items() if float(v) > 0}
    return balances

# Output: {'ZUSD': '1234.56', 'XXBT': '0.12345678', 'XETH': '2.50'}
```

```javascript
// Node.js
const crypto = require('crypto');
const https = require('https');
const querystring = require('querystring');

function getSignature(path, params, secret) {
  const nonce = params.nonce;
  const encoded = nonce + querystring.stringify(params);
  const sha256 = crypto.createHash('sha256').update(encoded).digest();
  const message = Buffer.concat([Buffer.from(path), sha256]);
  const hmac = crypto.createHmac('sha512', Buffer.from(secret, 'base64'));
  return hmac.update(message).digest('base64');
}

async function krakenPrivate(endpoint, params = {}) {
  params.nonce = Date.now().toString();
  const path = `/0/private/${endpoint}`;
  const postData = querystring.stringify(params);
  const signature = getSignature(path, params, process.env.KRAKEN_SECRET);
  
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.kraken.com',
      path, method: 'POST',
      headers: {
        'API-Key': process.env.KRAKEN_KEY,
        'API-Sign': signature,
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    };
    const req = https.request(options, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    });
    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Usage:
krakenPrivate('Balance').then(r => console.log(r.result));
```

### Place a Market/Limit Order

```python
# Market buy
def market_buy(pair: str, volume: str) -> dict:
    return kraken_private("AddOrder", {
        "ordertype": "market",
        "type": "buy",
        "pair": pair,
        "volume": volume,
    })

# Limit buy with stop-loss and take-profit
def limit_buy_with_stops(pair: str, volume: str, price: str, 
                          stoploss: str, takeprofit: str) -> dict:
    return kraken_private("AddOrder", {
        "ordertype": "limit",
        "type": "buy",
        "pair": pair,
        "volume": volume,
        "price": price,
        "close[ordertype]": "stop-loss-limit",
        "close[price]": stoploss,
        "close[price2]": takeprofit,
    })

# Example: Buy 0.001 BTC at $40,000, stop at $38,000
result = limit_buy_with_stops(
    pair="XBTUSD", volume="0.001", 
    price="40000", stoploss="38000", takeprofit="45000"
)
print(result)  # {'error': [], 'result': {'txid': ['OXXXXXX-...'], 'descr': {...}}}
```

### Check Order Status

```python
def get_order_status(txid: str) -> dict:
    result = kraken_private("QueryOrders", {"txid": txid})
    if result["error"]:
        return {"error": result["error"]}
    
    order = result["result"][txid]
    return {
        "txid": txid,
        "status": order["status"],        # open/closed/canceled/expired
        "type": order["descr"]["type"],   # buy/sell
        "price": order["descr"]["price"],
        "volume": order["vol"],
        "filled": order["vol_exec"],
        "cost": order.get("cost", "0"),
    }
```

### Get Market Data

```python
def get_market_data(pair: str) -> dict:
    # Ticker (current price)
    ticker_result = kraken_public("Ticker", {"pair": pair})
    pair_data = list(ticker_result["result"].values())[0]
    
    # OHLC (last 24 hourly candles)
    ohlc_result = kraken_public("OHLC", {"pair": pair, "interval": 60})
    candles = list(ohlc_result["result"].values())[0]
    
    return {
        "bid": pair_data["b"][0],
        "ask": pair_data["a"][0],
        "last": pair_data["c"][0],
        "volume_24h": pair_data["v"][1],
        "high_24h": pair_data["h"][1],
        "low_24h": pair_data["l"][1],
        "candles_1h": [
            {"time": c[0], "open": c[1], "high": c[2], 
             "low": c[3], "close": c[4], "volume": c[6]}
            for c in candles[-24:]
        ]
    }
```

---

## 7. Testing Strategy

### Phase 1: Sandbox Testing (Futures only)

Kraken **Spot has no sandbox**. But Futures has a full demo environment:

1. Register at `demo-futures.kraken.com`
2. Generate demo API keys there
3. Use `https://demo-futures.kraken.com/derivatives/api/v3/` as base URL
4. Test order placement, cancellation, position management
5. Port logic to Spot when confident

### Phase 2: Paper Trading Layer

Add a "dry run" mode to your scripts:

```python
DRY_RUN = True  # Set False when ready for real money

def place_order(pair, side, volume, price=None, ordertype="market"):
    order_details = {
        "pair": pair, "type": side,
        "ordertype": ordertype, "volume": volume,
        "price": price or get_current_price(pair),
    }
    
    if DRY_RUN:
        print(f"[DRY RUN] Would place: {order_details}")
        return {"dry_run": True, "simulated": order_details}
    
    return kraken_private("AddOrder", order_details)
```

### Phase 3: Tiny Real Money Testing

1. **Fund a test amount** — put $20-50 in Kraken
2. **Set hard limits** in `SAFETY_CONFIG`: max $10/order, $25/day
3. **Trade illiquid pairs** you don't mind owning
4. **Test with minimum order sizes** (Kraken BTC minimum: ~0.0001 BTC, ~$4)
5. **Monitor the trade log** after each test run

### Phase 4: Production Rollout

Checklist before going live:
- [ ] All API keys stored securely (env vars, not hardcoded)
- [ ] IP whitelist set on Kraken account
- [ ] Emergency stop mechanism tested
- [ ] Trade log working and persistent
- [ ] Rate limiting implemented and tested
- [ ] Order confirmation prompts working in OpenClaw
- [ ] Max order size limits configured
- [ ] Alerts set up (Telegram notification on each trade)
- [ ] Separate API key per strategy

---

## 8. OpenClaw Skill File Template

Save as `~/.openclaw/skills/kraken/SKILL.md`:

```markdown
---
name: kraken
description: Kraken crypto exchange — check balances, place orders, get market prices, run DCA or rebalancing. Use when user asks about crypto portfolio, BTC/ETH prices, or wants to trade on Kraken.
---

# Kraken Trading Skill

## Credentials
Load from environment: source ~/.openclaw/secrets/kraken.env
Variables: KRAKEN_API_KEY, KRAKEN_API_SECRET

## Scripts Location
~/.openclaw/skills/kraken/scripts/

## Available Operations

### Market Data (safe, read-only)
python3 scripts/market_data.py --pair XBTUSD

### Account Balance (safe, read-only)  
python3 scripts/balance.py

### Place Order (DANGEROUS — always confirm with user first)
python3 scripts/place_order.py \
  --pair XBTUSD \
  --side buy \
  --type limit \
  --price 40000 \
  --volume 0.001 \
  --dry-run  # Remove --dry-run after user confirms

## Safety Rules
1. ALWAYS show order details and ask for explicit confirmation before placing
2. Check EMERGENCY_STOP file exists → halt immediately if so
3. Never place orders > $100 without stating amount clearly
4. Log every action to trade-log.jsonl
5. If any error occurs, report it — don't silently retry

## Common Pair Names
- BTC/USD → XBTUSD
- ETH/USD → ETHUSD  
- SOL/USD → SOLUSD
- BTC/EUR → XBTEUR
```

---

## Quick Start Checklist

1. **Create Kraken account** → verify identity (needed for higher tier)
2. **Generate API key**: Kraken → Security → API → Add key (no Withdraw permission)
3. **Store credentials**: `~/.openclaw/secrets/kraken.env` (chmod 600)
4. **Install SDK**: `pip install python-kraken-sdk` or `pip install ccxt`
5. **Test read-only first**: fetch balance, get ticker — no orders yet
6. **Create skill folder**: `~/.openclaw/skills/kraken/SKILL.md`
7. **Test paper trading**: set DRY_RUN=True, verify logic
8. **Test with $10**: one small market order, check fill
9. **Build strategy script**: DCA / rebalance / grid with safety limits
10. **Set up Telegram alerts**: OpenClaw message tool to notify on trades

---

*API docs: https://docs.kraken.com/*  
*python-kraken-sdk: https://python-kraken-sdk.readthedocs.io/*  
*Futures demo: https://demo-futures.kraken.com/*
