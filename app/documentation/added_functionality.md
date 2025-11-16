# <span style="color:darkred">App Functionality</span>

This document explains the features in the PastRxUI application.

There are 3 steps to create a file for the BestDose software:

1. **Provide patient information**
2. **Provide administration data**
3. **Provide concentration data**

---

<details open>
<summary><strong><span style="color:#2993D6">1. Patient Information</span></strong></summary>

This step is straightforward — the user needs to provide all necessary information in the Patient Info tab. Once complete, proceed to the **Administration Tab**.

> **Note:** Some drugs have been pre-configured, but you can manually enter any drug name. The same applies to Hospital name — just click "Add..." once entered (see image below).
>
> ![Hospital selection](image.png)

</details>

---

<details open>
<summary><strong><span style="color:#2993D6">2. Administration Tab</span></strong></summary>

You need to create a complete weight and administration history for the patient.

<details>
<summary><strong><span style="color:#2993D6">2.1 Weight History</span></strong></summary>

**Weight history is mandatory** (at least one value is required).

To create the weight history:
1. Select the date/time
2. Enter the weight value and unit
3. Click the **Add Weight** button

You can select a specific calculation method using the weight formula input (TBW, BSA, or Modified weight).

![Weight entry form](image-1.png)

This will add the weight to the Weight History table below. To edit or delete an entry:
- Click on any field to manually edit the value
- Click the trash icon at the end of the row to delete it

![Weight history table](image-2.png)

The table displays Date, Time, and Weight Value — the variables required for BestDose. The application also tracks the formula used, total weight, body surface area, and weight unit (lbs or kg) to assist users.

</details>

<details>
<summary><strong><span style="color:#2993D6">2.2 Administration History</span></strong></summary>

Similar to weight history, you need to create a complete administration history.

First, select the **route of administration**, as this determines the required data fields.

<details>
<summary><strong><span style="color:#2993D6">2.2.1 Oral or Extravascular Administration</span></strong></summary>

Provide:
- Date/Time
- Dose

> **Note:** There is no subcutaneous route in BestDose. Use the IM route if needed.

![Oral administration](image-7.png)

</details>

<details>
<summary><strong><span style="color:#2993D6">2.2.2 IV (Non-Continuous) Administration</span></strong></summary>

Provide:
- Date/Time
- Dose
- Infusion duration (hours)

For **multiple doses**, use the Multiple Dose option to create several administrations spaced by the interval specified in "Dose Interval (hours)".

![IV administration](image-6.png)

</details>

<details>
<summary><strong><span style="color:#2993D6">2.2.3 Continuous IV Administration</span></strong></summary>

For continuous infusion, more information is required. The dose administered will be calculated based on:
- Beginning and end date/time
- Electronic syringe volume (mL)
- Dose of drug in the syringe (mg)
- Infusion rate (mL/h)

The app calculates the dose administered over the time period.

![Continuous IV](image-5.png)

</details>

</details>

<details>
<summary><strong> <span style="color:#2993D6"> 2.3 Administration History Table </span></strong></summary>

The table displays the administration history. <br>
Creatinine and weight values used to calculate creatinine clearance come from the Covariates menu. Select the desired formula for renal function calculation. <br>
The table shows creatinine value, unit, and formula used.

![Administration history table](image-9.png)

> **Important:** Due to BestDose limitations, the weight used for renal function calculation is the weight in the "Weight" input field. Always ensure the correct weight is entered before adding a new administration, otherwise the Cockcroft-Gault formula will use an incorrect weight.

</details>

<details>
<summary><strong><span style="color:#2993D6">2.4 Next Dose and Options</span></strong></summary>

This menu provides information about the next dose to be administered and options for BestDose file creation.

![Next dose settings](image-8.png)

You can modify:
- Unit used for creatinine and weight
- Whether the patient is African American
- Whether to denormalize the creatinine clearance

![Options settings](image-10.png)

</details>

</details>

---

<details>
<summary><strong><span style="color:#2993D6">3. Concentration Correction</span></strong></summary>

**BestDose cannot accept concentrations > 100.**

This app automatically rescales concentrations higher than 100 by dividing them by 10. While this is always applied when saving files, the only way to load the original data is to use the `.json` file created alongside the `.mb2` file.

</details>