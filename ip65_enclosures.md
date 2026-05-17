# IP65 Hardware Enclosure Options

For actual installation and deployment (especially outdoors or in dusty/humid environments), you need a functional IP65-rated enclosure. Here are two highly practical approaches for housing the soldered ESP32 and PZEM boards safely.

---

## Option 1: Standard ABS Junction Box with Clear Lid
**Estimated Cost: ~$4 - $8 per unit**

![Clear Lid IP65 Box](file:///C:/Users/USER/.gemini/antigravity/brain/79e94d57-60ff-4489-be82-2d569daa9c36/ip65_junction_box_1778337953152.png)

This is the most common industry standard for DIY/custom smart meters.
* **Material**: Grey ABS plastic base with a transparent Polycarbonate lid and a rubber waterproof gasket.
* **Why it works**: The clear lid allows you to see the indicator LEDs on the ESP32 and PZEM without opening the box.
* **Assembly**: 
  1. Use standoffs or strong double-sided mounting tape to secure the ESP32 and PZEM to the base.
  2. Drill holes in the bottom and install **PG7 or PG9 Cable Glands**.
  3. Route the AC mains power and the CT clamp wire through the glands. Tightening the glands seals the box completely against water and dust.

---

## Option 2: Rugged Industrial Enclosure (Matte Black)
**Estimated Cost: ~$6 - $12 per unit**

![Rugged IP65 Enclosure](file:///C:/Users/USER/.gemini\antigravity\brain\79e94d57-60ff-4489-be82-2d569daa9c36\ip65_rugged_enclosure_1778337966250.png)

For a more premium, durable "finished product" look, a solid black polycarbonate enclosure with external mounting flanges is ideal.
* **Material**: High-impact polycarbonate or die-cast aluminum (if heat dissipation is needed).
* **Why it works**: External mounting tabs mean the installer can screw the box to the wall *without* having to open the waterproof seal to access internal screw holes.
* **Assembly**:
  1. Similar internal mounting as Option 1.
  2. Because the lid is opaque, you might want to drill a small hole for a 3mm external status LED, sealed with silicone, to show the device is powered and connected to Wi-Fi.
  3. Use heavy-duty brass or nylon cable glands on the bottom edge for the wiring.
