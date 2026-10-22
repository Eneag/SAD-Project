# SAD-Project
**CubeSat 3U Attitude Dynamics & Control: Project Plan**

## Project Overview
- **Spacecraft:** CubeSat 3U 
- **Attitude Parameterization:** Euler Angles 
- **Primary Sensor:** Sun Sensor 
- **Primary Actuator:** Constant Thrust Jets 
- **Environmental Torques:** Gravity Gradient, Magnetic Torque, Aerodynamic Drag 

---

## Team Responsibilities & Subgroups
While the entire team is responsible for the final Simulink model and the report, the primary development is divided into two operational subgroups:

### Subgroup 1: Initial Phase & Sensors
- **Vats (Attitude Determination):** Modeling the Sun Sensor output and developing determination algorithms (e.g., TRIAD or filters).
- **Aurora (Detumbling):** Developing the control logic to damp the initial tumbling motion using the available actuators.

### Subgroup 2: Operational Phase & Pointing
- **Saverio (Slew Maneuver):** Designing the large-angle reorientation maneuver (e.g., utilizing a phase plane and Schmitt trigger for the constant thrust jets).
- **Enea (Target Tracking):** Developing the 3-axis stabilization controller to maintain fine pointing against environmental disturbances.

---

## PHASE 1: Physical Modeling & Setup (Late October – Mid-November)

- **Full Team:**
  - Initialize the GitHub repository and set up a shared `init.m` script for all physical constants (inertia, orbit parameters, jet thrust).
  - Build the core Simulink dynamics and kinematics blocks (Euler equations + 3-1-2/3-1-3 kinematics).
  - Integrate the assigned environmental disturbance torques (Gravity Gradient, Magnetic, Aerodynamic Drag).
- **Subgroup 1:** Vats sets up the Sun Sensor model (including field of view and noise); Aurora researches specific detumbling control laws suitable for constant thrust jets.
- **Subgroup 2:** Saverio and Enea build the non-linear "on/off" Simulink model for the constant thrust jets and define the mission's pointing requirements.

---

## PHASE 2: Control & Determination Development (Mid-November – Early December)

- **Subgroup 1:** Vats implements the Attitude Determination block. Aurora develops and isolates the Detumbling controller to ensure it successfully drives initial angular rates ($\omega$) to near zero.
- **Subgroup 2:** Saverio implements the Slew Maneuver logic to rotate the spacecraft to the target attitude. Enea develops the Target Tracking controller to receive measured attitude data from Vats and command the jets to hold the nominal pointing.

---

## PHASE 3: Integration & Simulation (Mid-December – December 24)

- **Full Team:**
  - Merge all modules into the main `.slx` file on GitHub.
  - Implement state-machine logic to transition between mission phases: **Tumbling** -> **Detumbling (Aurora)** -> **Slew (Saverio)** -> **Target Tracking (Enea)**.
  - Run a full simulation of at least one complete orbit.
  - Extract and save all required plots (Euler angles, angular velocities, pointing error, jet fuel consumption) and calculate statistical pointing performance.

---

## PHASE 4: Report & Conclusion (December 25 – January 6)

- **Full Team (via Overleaf):**
  - Draft the introduction, justifying the chosen environmental torques and pointing requirements.
- **Vats:** Drafts the Sensors & Determination section.
- **Aurora:** Drafts the Detumbling section.
- **Saverio:** Drafts the Slew Maneuver section.
- **Enea:** Drafts the Tracking & Stabilization section.
- **Final Formatting:** Format all Simulink plots with clear axis labels and units, ensuring the final PDF does not exceed the 20-page limit (excluding cover and index).
- **Final Delivery:** Upload `GroupNumber.pdf` and `GroupNumber.zip` (Simulink files) to WeBeep by the strict **January 7, 2027** deadline.
