# Rule Engine Blueprint (Draft)

This blueprint translates the written rules of Twenty Nine into logical components for future Dart code.  
It is not executable code — it is a structured design map that will guide development.

---

## Core Entities

- **Card**
  - Properties: `suit`, `rank`, `pointValue`

- **Deck**
  - Properties: list of 32 `Card` objects
  - Methods: `shuffle()`, `deal()`

- **Player**
  - Properties: `hand` (list of cards), `team`, `score`
  - Methods: `playCard()`, `bid()`, `declareTrump()`

- **Team**
  - Properties: `players` (2), `totalScore`
  - Methods: `addPoints()`, `resetRound()`

- **GameState**
  - Properties: `currentDealer`, `currentBid`, `trumpSuit`, `currentTrick`, `roundNumber`
  - Methods: `startRound()`, `endRound()`, `calculateWinner()`

---

## Rule Engines

- **BiddingEngine**
  - Manages the bidding sequence
  - Validates minimum bid (16+)
  - Records the highest bidder in `GameState`

- **TrumpEngine**
  - Handles Blind Trump and 7th Card Trump
  - Validates trump declaration rules
  - Records the chosen trump suit in `GameState`

- **TrickEngine**
  - Enforces “follow suit if possible”
  - Determines trick winner each round
  - Updates trick history and assigns the next lead

- **ScoringEngine**
  - Calculates points from tricks
  - Applies round scoring (+1 / -1)
  - Handles challenge multipliers (Double, Re-Double, Full Set, Single Hand)
  - Applies Marriage bonus/penalty
  - Checks redeal conditions

---

## Flow of a Round

1. **Shuffle & Deal**
   - DeckEngine shuffles the deck
   - Each player receives 8 cards

2. **Bidding Phase**
   - Players bid in clockwise order
   - BiddingEngine validates bids
   - GameState records the highest bidder

3. **Trump Declaration**
   - TrumpEngine manages Blind Trump or 7th Card Trump
   - GameState records the trump suit

4. **Trick Play (8 Tricks)**
   - TrickEngine enforces legal play
   - Determines trick winner
   - Updates trick history and assigns next lead

5. **Scoring**
   - ScoringEngine calculates team points
   - Applies challenges and bonuses
   - Validates redeal conditions

6. **Round Result**
   - Winning team receives +1 (or adjusted by challenges)
   - Losing team receives -1 (or adjusted by challenges)
   - If bidder’s team wins all 8 tricks → +2 bonus

7. **Next Dealer**
   - Normally rotates clockwise
   - Exception: in Single Hand, the winner (or the one who beats it) becomes the next dealer

---

## Future Extensions

- **PersistenceEngine**
  - Saves and loads game state (e.g., Firebase integration)

- **UIAdapter**
  - Connects rule engine logic to Flutter UI screens

- **Analytics**
  - Tracks statistics such as win rates, average bids, and most common trump suits

---

## Notes
- This blueprint is **not code** — it is a design guide.  
- Each Engine will later become a Dart class or service.  
- Engines can reference `rules.json` to dynamically enforce rules without hardcoding.