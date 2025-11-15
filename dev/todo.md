## toolbox
- [x] split toolbox 
  - [x] "Use mod weight"/ Use BSA are only for the file to be computed" => create report option in header or open a modal to chose option when creating the mb2 file
  - [x] other option should be in the administration tab
- [x] Remove Phone Number in patient information

## renal function
- [w] renal calculator shoulb be an option in the lab values
- [x] renal function is not calculated when adding a new row
- [x] improve the ergonomics of adding dosing or weight

## administration tab
- [x] mutliple dose is not working properly
- [x] add observe to sort data by date/time if user change date/time in the rhandsontable
- [x] observe to update the R object if user change data in the rhandsontable
- [ ] Change table format to DT and allow editing
- [x] add administration history and weight history in a fixed space with scroll bar
- [ ] Mofidy header in dosing, weight and tdm history to be more user friendly (add units in the header, format date/time properly)
  - [ ] mod weight type should disaplay "Weight Type" instead of "mod weight"


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
- [x] create a .json file that save all the informations in the mb2.file plus all the information necessary to have a fully functionning reading when loading including :
    - [x] The settings from the toolbox (weight type, creatinine unit, african american, denorm crcl) etc.
    - [x] If concentration was divided by 10 or not
    - [x] The full weight history (the current weight_history and add the weight unit in a new column that should be implemented based on selected weight unit in menu) 
    - [x] the full dosing history (best dose only for creatinine clearance and not creatinine value when we want to have both, also include the unit of creatinine used)
- [x] Loading file should be possible with either the mb2 file or the json file. Don't have a fallback in place (next point). this allow backward compatibility with already existing mb2 files
- [x] if json is not loaded properly, just default to everything staying empty and give a notification to the user (danger either json corrected or not found, load the mb2 file only)
- [x] if concentration, dose; and infusion were divided by 10 based on the settings in the json file, correct the values during the reading of the json file
  

## patient info
- [ ] add file display in patient info tab