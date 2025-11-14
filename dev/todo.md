## toolbox
- [ ] split toolbox 
  - [ ] "Use mod weight"/ Use BSA are only for the file to be computed" => create report option in header or open a modal to chose option when creating the mb2 file
  - [ ] other option should be in the administration tab
- [ ] Remove Phone Number in patient information

## renal function
- [ ] renal calculator shoulb be an option in the lab values
- [ ] renal function is not calculated when adding a new row
- [ ] improve the ergonomics of addiv dosing or weight

## administration tab
- [ ] mutliple dose is not working properly
- [ ] add observe to sort data by date/time if user change date/time in the rhandsontable
- [ ] Optionnal change table format to Reacttable if editable or to DT if Reactable can't be edited
- [ ] add administration history and weight history in a fixed space with scroll bar


## general functions
- [x] add file loading in UI
  - [x] add button to load mb2 file 
  - [x] read the mb2 file
  - [x] populate the UI with the data from the mb2 file

## mb2 file
- [ ] add option to choose weight formula when writing mb2 file (this is performed by the ticked value in toolbox) bsa/tbw or modified weight needs to be exclusive options, only one can be selected at a time
- [ ] use a reserved space in the mb2 file to if concentration/dose are corrected (numeric value either 1 (no correction) or 10 (which is the correction applied))
- [ ] use the space to mutliply the dose by the correction factor when loading the mb2 file

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