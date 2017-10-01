REPORT ZEXCEL_PASSWD.
include ole2incl.

data: e_sheet type ole2_object.
data: e_appl  type ole2_object.
data: e_work  type ole2_object.
data: e_cell  type ole2_object.
data: e_wbooklist type ole2_object.

data: field_value(30) type c.

parameters: p_file type localfile default 'C:Test.xls'.

start-of-selection.


* Start the application
  create object e_appl 'EXCEL.APPLICATION'.
  set property of e_appl 'VISIBLE' = 0.

* Open the file
  call method of e_appl 'WORKBOOKS' = e_wbooklist.
  get property of e_wbooklist 'Application' = e_appl .
  set property of e_appl 'SheetsInNewWorkbook' = 1 .
  call method of e_wbooklist 'Add' = e_work .
  get property of e_appl 'ActiveSheet' = e_sheet .
  set property of e_sheet 'Name' = 'Test' .





* Write data to the excel file
  do 20 times.

* Create the value
    field_value  = sy-index.
    shift field_value left deleting leading space.
    concatenate 'Cell' field_value into field_value separated by space.


* Position to specific cell  in  Column 1
    call method of e_appl 'Cells' = e_cell
           exporting
                #1 = sy-index
                #2 = 1.
* Set the value
    set property of e_cell 'Value' = field_value .


* Position to specific cell  in  Column 2
    call method of e_appl 'Cells' = e_cell
           exporting
                #1 = sy-index
                #2 = 2.
* Set the value
    set property of e_cell 'Value' = field_value .


* Position to specific cell  in  Column 3
    call method of e_appl 'Cells' = e_cell
           exporting
                #1 = sy-index
                #2 = 3.
* Set the value
    set property of e_cell 'Value' = field_value .

  enddo.



** Close the file
  get property of e_appl 'ActiveWorkbook' = e_work.
  call method of e_work 'SAVEAS'
        exporting
            #1 = p_file
            #2 = 1           "" Don't ask me when closing
            #3 = 'rich'    "" Password
            #4 = 'rich'.     "" Reserved for Password[/b]

  call method of e_work 'close'.

* Quit the file
  call method of  e_appl  'QUIT'.

* Free them up
  free object e_cell.
  free object e_sheet.
  free object e_work.
  free object e_wbooklist.
  free object e_appl.