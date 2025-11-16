# <span style="color:darkred">Options Explanation</span>

This document explains the various options available in the PastRxUI application.

---

<details open>
<summary><strong><span style="color:#2993D6">1. Language</span></strong></summary>

- **Description**: Allows users to select the language for the application's interface.
- **Options**:
  - English (en)
  - French (fr)
- **Default**: French
- **Impact**: Changes all text labels, buttons, and messages to the selected language.

![alt text](image-13.png)
</details>

---

<details open>
<summary><strong><span style="color:#2993D6">2. Type of Weight in Report</span></strong></summary>

- **Description**: Determines which weight calculation is used in the BestDose file. The default is Total Body Weight (TBW).
- **Options**:
  - Total Weight (TBW): Uses the patient's total body weight.
  - Modified Weight: Applies adjustments based on specific formulas.
  - Body Surface Area (BSA): Calculates weight based on body surface area.


![alt text](image-11.png)

</details>


---

<details open>
<summary><strong><span style="color:#2993D6">3. Renal Calculators</span></strong></summary>

- **Description**: Tools for calculating renal function, including creatinine clearance and glomerular filtration rate (GFR).
- **Inputs**:
  - Creatinine levels
  - Patient weight
  - Age, sex
- **Formulas**: Supports multiple renal estimation formulas (e.g., Cockcroft-Gault, MDRD).
- **Output**: Calculate the renale function based on patient sex, age, creatinine and weight entered in the calculator.

This may be used to update renal function values in the administration table.


![alt text](image-14.png)

</details>