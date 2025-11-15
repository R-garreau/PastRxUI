## toolbox
- [x] split toolbox 
  - [x] "Use mod weight"/ Use BSA are only for the file to be computed" => create report option in header or open a modal to chose option when creating the mb2 file
  - [x] other option should be in the administration tab
- [x] Remove Phone Number in patient information

## renal function
- [w] renal calculator shoulb be an option in the lab values
- [ ] renal function is not calculated when adding a new row
- [ ] improve the ergonomics of adding dosing or weight

## administration tab
- [x] mutliple dose is not working properly
- [x] add observe to sort data by date/time if user change date/time in the rhandsontable
- [x] observe to update the R object if user change data in the rhandsontable
- [ ] Optionnal change table format to Reacttable if editable or to DT if Reactable can't be edited
- [x] add administration history and weight history in a fixed space with scroll bar


## general functions
- [x] add file loading in UI
  - [x] add button to load mb2 file 
  - [x] read the mb2 file
  - [x] populate the UI with the data from the mb2 file


## translation
- [ ] make the translation system to work properly
- [ ] add flag icons to choose language in the select input (flag + fr or eng)
- [ ] add translation for toolbox
- [ ] add translation for notification messages

## add validation for inputs
 - [ ] add validation based on the validators.R file


## documentation
- [ ] Add a short documentation in a closable box on the main page to explain very general functionality of the app
- [ ] add information by using popovers or tooltips to explain specific inputs or options

## mb2 file (creation/saving and loading)
- [x] add option to choose weight formula when writing mb2 file (this is performed by the ticked value in toolbox) bsa/tbw or modified weight needs to be exclusive options, only one can be selected at a time
- [ ] use a reserved space in the mb2 file to if concentration/dose are corrected (numeric value either 1 (no correction) or 10 (which is the correction applied)) SUPERSEEDED by the .json
- [ ] use the space to mutliply the dose by the correction factor when loading the mb2 file
- [ ] create a .json file that save all the informations in the mb2.file plus all the information necessary to have a fully functionning reading when loading including :
    - [ ]  The settings from the toolbox (weight type, creatinine unit, african american, denorm crcl) etc.
    - [ ]  If concentration was divided by 10 or not
    - [ ]  The full weight history (the current weight_history and add the weight unit in a new column that should be implemented based on selected weight unit in menu) 
    - [ ] the full dosing history (best dose only for creatinine clearance and not creatinine value when we want to have both, also include the unit of creatinine used)
  