# Options Explanation

This document explains the various options available in the PastRxUI application.

---

<details open>
<summary><strong>1. Language</strong></summary>

- **Description**: Allows users to select the language for the application's interface.
- **Options**:
  - English (en)
  - French (fr)
- **Default**: French
- **Impact**: Changes all text labels, buttons, and messages to the selected language.

</details>

---

<details open>
<summary><strong>2. Type of Weight in Report</strong></summary>

- **Description**: Determines which weight calculation is used in reports and calculations.
- **Options**:
  - Total Weight (TBW): Uses the patient's total body weight.
  - Modified Weight: Applies adjustments based on specific formulas.
  - Body Surface Area (BSA): Calculates weight based on body surface area.
- **Default**: Total Weight
- **Impact**: Affects dosing calculations and renal function estimates.

</details>

---

<details open>
<summary><strong>3. Special Unit Selection in Administration</strong></summary>

- **Description**: Allows selection of special units for drug administration, such as concentration units or infusion rates.
- **Options**: Varies depending on the drug and administration route.
- **Impact**: Ensures accurate dosing and compatibility with BestDose software.

</details>

---

<details open>
<summary><strong>4. Renal Calculators</strong></summary>

- **Description**: Tools for calculating renal function, including creatinine clearance and glomerular filtration rate (GFR).
- **Inputs**:
  - Creatinine levels
  - Patient weight
  - Age, sex
- **Formulas**: Supports multiple renal estimation formulas (e.g., Cockcroft-Gault, MDRD).
- **Output**: Estimated renal clearance values used in dosing adjustments.

</details>