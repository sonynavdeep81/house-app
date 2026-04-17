# Cement & Sand Calculation — Boundary Wall

## Wall Configuration
- Two bricks placed parallel (width-to-width: 4 + 4 = 8 inches)
- Mortar fills the gap between them and on outer faces → total wall = **9 inches wide**
- Wall thickness = brick length = **9 inches = 0.75 ft**

---

## Step-by-Step Example
**60 ft wall, 4 layers, 9×4×4 inch bricks, mortar ratio 1:3, 50 kg bags**

### Step 1 — Convert brick dimensions to feet
- Length = 9 ÷ 12 = 0.75 ft
- Width  = 4 ÷ 12 = 0.333 ft
- Height = 4 ÷ 12 = 0.333 ft

### Step 2 — Count bricks
- Bricks per row = ceil(60 ÷ 0.75) = 80
- × 2 rows (inner + outer) = 160 bricks per layer
- × 4 layers = **640 bricks total**

### Step 3 — Wall volume vs brick volume
- Wall volume  = 60 × (4×4 ÷ 12) × 0.75 = 60 × 1.333 × 0.75 = **60 cft**
- Brick volume = 640 × (0.75 × 0.333 × 0.333) = 640 × 0.0833 = **53.33 cft**
- Mortar (wet) = 60 − 53.33 = **6.67 cft**

### Step 4 — Wastage and dry volume factor
- × 1.20 (20% wastage — mortar lost during mixing/application)
  → 6.67 × 1.20 = **8.0 cft**
- × 1.33 (dry volume factor — dry ingredients shrink when water is added)
  → 8.0 × 1.33 = **10.64 cft** total dry material needed

### Step 5 — Split by ratio 1:3 (1 part cement : 3 parts sand)
- Total parts = 1 + 3 = 4
- Cement = 10.64 ÷ 4 = **2.66 cft**
- Sand   = 10.64 × 3 ÷ 4 = **7.98 cft**

### Step 6 — Convert cement cft to bags
- Formula: **kg ÷ 40 = cft** (50 kg bag → 50 ÷ 40 = 1.25 cft)
- Bags = ceil(2.66 ÷ 1.25) = ceil(2.13) = **3 bags**

---

## Final Result (60 ft wall, 4 layers, 1:3 ratio)
| Material | Quantity |
|----------|----------|
| Cement   | 3 bags (50 kg each) |
| Sand     | 8 cft |

---

## Key Factors Explained
| Factor | Value | Reason |
|--------|-------|--------|
| Wastage | × 1.20 | 20% mortar lost during mixing and application |
| Dry volume | × 1.33 | Dry mix compacts when water is added |
| Bag conversion | kg ÷ 40 | 50 kg bag = 1.25 cft (standard in India) |
