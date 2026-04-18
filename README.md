# FIFA World Cup 2034 — AI Crowd Management System
### Team F013 | Semester 252 | Aramco Stadium, Dhahran

---

## What This System Does

Cameras at stadium gates detect and count people using AI. The system predicts which gate is getting too crowded, recommends the best gate to fans on their phones, and sends alerts to security staff. All data is stored encrypted in a database.

```
Camera → AI Backend → Encrypted Database → Mobile App (fans) + Dashboard (security)
```

---

## Folder Structure

```
Senior Project/
├── backend/          → AI engine (YOLO detection, ML models, REST API)
├── crowd_app/        → Flutter mobile app (for fans)
├── supabase-backend/ → Database schema and migrations
├── dashboard/        → Web dashboard (for security staff)
└── UI Design/        → Figma design reference only (not meant to run)
```

---

## Who Owns What

| Folder | Owner |
|--------|-------|
| `backend/` | Rana |
| `dashboard/` | Rana |
| `crowd_app/` | Rimas |
| `supabase-backend/` | Rimas |

---

## Prerequisites — Install These First

### Everyone needs:
| Tool | Version | Download |
|------|---------|----------|
| Python | **3.11.x** | https://www.python.org/downloads/release/python-3119/ |
| Flutter | Latest stable | https://docs.flutter.dev/get-started/install |
| Node.js | 18+ | https://nodejs.org |
| Docker Desktop | Latest | https://www.docker.com/products/docker-desktop |
| Git | Latest | https://git-scm.com |

> ⚠️ Python must be **3.11** — not 3.12, 3.13, or 3.14. TensorFlow and numpy require 3.11.

### Verify your installs (run in terminal):
```bash
python --version      # must say 3.11.x
flutter --version     # any recent version
node --version        # must say 18+
docker --version      # any recent version
```

---

## Part 1 — Database Setup (Supabase)

> Run this first. Everything else depends on the database.

### Step 1: Install Supabase CLI
```bash
npm install -g supabase
```

### Step 2: Start local Supabase
```bash
cd supabase-backend
npx supabase start
```

Wait for it to finish. You will see:
```
Studio URL:  http://127.0.0.1:54323   ← open this to see the database visually
Project URL: http://127.0.0.1:54321
```

### Step 3: Apply all database migrations
```bash
npx supabase db reset
```

This creates all tables and applies AES-256 encryption automatically.

### Step 4: Verify (optional)
Open `http://127.0.0.1:54323` in your browser → Table Editor → you should see tables: `stadium`, `zone`, `gate`, `metric_window`, `prediction`, `alert`, etc.

### Supabase credentials (for other parts):
```
URL:      http://127.0.0.1:54321
Anon Key: sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH
```

> Keep Supabase running in the background while using the rest of the system.

---

## Part 2 — AI Backend Setup

> This is the AI engine that processes camera footage.

### Step 1: Create Python 3.11 virtual environment
```bash
cd backend
py -3.11 -m venv venv
```

### Step 2: Activate the virtual environment

**Windows:**
```bash
venv\Scripts\activate
```
**Mac/Linux:**
```bash
source venv/bin/activate
```

You will see `(venv)` appear at the start of your terminal line.

### Step 3: Install dependencies
```bash
pip install -r requirements.txt
```
> This takes 5–10 minutes. TensorFlow and PyTorch are large packages.

### Step 4: Run the backend
```bash
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

You should see:
```
[boot] Loading YOLO ...
[boot] Loading DeepSort tracker ...
[supabase] Connected to local Supabase
Uvicorn running on http://0.0.0.0:8000
```

### Step 5: Verify
Open `http://localhost:8000/api/v1/metrics/latest` in your browser.
You should see JSON with crowd data updating every few seconds.

### API Documentation
Full interactive API docs: `http://localhost:8000/docs`

### Important config (top of `api.py`):
```python
CAMERA_MODE  = True   # True = live webcam, False = video files
CAMERA_INDEX = 0      # webcam index (0 = built-in, 1 = external)
```
> When physical stadium cameras arrive, change `CAMERA_INDEX` to match the camera.

> Keep backend running in the background.

---

## Part 3 — Mobile App Setup (Flutter)

> The fan-facing app that shows gate recommendations and crowd levels.

### Step 1: Install Flutter dependencies
```bash
cd crowd_app
flutter pub get
```

### Step 2: Run the app in Chrome (web)
```bash
flutter run -d chrome
```

The app opens in Chrome. When asked for location access → click **Allow**.

### Step 3: Run on Android phone (optional)
Connect your phone via USB, enable Developer Mode, then:
```bash
flutter run
```

> ⚠️ When running on a real phone (not Chrome), change the API URL in `lib/services/api_service.dart`:
> ```dart
> const String _base = 'http://YOUR_COMPUTER_IP:8000';
> ```
> Find your computer's IP: run `ipconfig` on Windows, look for IPv4 address.

### Gate Coordinates
When you know the real demo location, update gate GPS coordinates in:
`lib/services/gate_coordinates.dart`

```dart
GateCoord(id: 1, name: 'Gate 1', lat: YOUR_LAT, lon: YOUR_LON, ...),
```
Right-click any location on Google Maps to copy coordinates.

---

## Part 4 — Dashboard Setup

> The security staff web dashboard.

```bash
cd dashboard
# (setup instructions to be added by Rana)
```

---

## Running the Full System

Open **4 terminals** and run one command in each:

| Terminal | Command | Purpose |
|----------|---------|---------|
| 1 | `cd supabase-backend && npx supabase start` | Database |
| 2 | `cd backend && venv\Scripts\activate && uvicorn api:app --host 0.0.0.0 --port 8000 --reload` | AI Backend |
| 3 | `cd crowd_app && flutter run -d chrome` | Mobile App |
| 4 | `cd dashboard && (dashboard command)` | Dashboard |

### Startup Order (important!)
```
1. Supabase first
2. Backend second
3. App and Dashboard last
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  Stadium Camera                  │
│              (Raspberry Pi + Camera)             │
└──────────────────────┬──────────────────────────┘
                       │ video feed
┌──────────────────────▼──────────────────────────┐
│              AI Backend (port 8000)              │
│   YOLO detection → DeepSort tracking             │
│   LightGBM forecast → Risk classification        │
│   Saves encrypted data to Supabase every 3s      │
└──────────┬───────────────────────┬──────────────┘
           │ REST API              │ Supabase RPC
┌──────────▼──────────┐  ┌────────▼──────────────┐
│   Flutter App       │  │  Supabase Database     │
│   (Fan's phone)     │  │  AES-256 encrypted     │
│   - Gate recommend  │  │  - metric_window       │
│   - GPS routing     │  │  - prediction          │
│   - Crowd alerts    │  │  - alert               │
└─────────────────────┘  │  - gps_event           │
┌─────────────────────┐  │  - gate_command        │
│   Web Dashboard     │  │  - audit_log           │
│   (Security staff)  │  └────────────────────────┘
│   - Live heatmap    │
│   - Gate control    │
└─────────────────────┘
```

---

## Encryption

All sensitive data is AES-256 encrypted **inside the database**. Plain values are never stored.

| Table | Encrypted Fields |
|-------|-----------------|
| `gps_event` | latitude, longitude |
| `metric_window` | density, arrivals, queue length, flow rate |
| `prediction` | density, wait time, congestion probability, severity |
| `alert` | severity, reason message |
| `gate_command` | command type, parameters |
| `audit_log` | full row snapshots |

To insert data, always use the provided RPC functions — never insert directly:
```sql
select insert_metric_window(1, 1, 1, 1.8, 14, 4, 12.5);
select insert_prediction(1, 1, 1, 1.8, 6.0, 0.18, 0.91, 'LOW', 15);
select insert_alert(1, 1, 1, 'HIGH', 'Density exceeds threshold');
```

---

## When Physical Hardware Arrives

### Raspberry Pi Camera:
1. Connect camera to Raspberry Pi
2. Find the camera index (usually 0 or 1)
3. In `backend/api.py` line 28–29:
```python
CAMERA_MODE  = True
CAMERA_INDEX = 0   # change if needed
```

### Gate Coordinates:
Update `crowd_app/lib/services/gate_coordinates.dart` with real GPS coordinates for each physical gate.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ModuleNotFoundError: cv2` | Run `pip install -r requirements.txt` inside `(venv)` |
| `py -3.11` not found | Install Python 3.11 from python.org |
| Flutter app shows fake data | Make sure backend is running on port 8000 |
| Supabase not starting | Make sure Docker Desktop is running |
| GPS shows "Live Location OFF" | Click Allow when browser asks for location |
| Backend exits immediately | Use `uvicorn api:app ...` not `python api.py` |
| App can't reach backend on phone | Use computer's local IP, not localhost |

---

## Team

| Name | Role | Components |
|------|------|------------|
| Rana | AI & Backend | `backend/`, `dashboard/` |
| Rimas | Mobile & Database | `crowd_app/`, `supabase-backend/` |

**Course:** Senior Project — Semester 252
**Stadium:** Aramco Stadium, Dhahran
**Event:** FIFA World Cup 2034
