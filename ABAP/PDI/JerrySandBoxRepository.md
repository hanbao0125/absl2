# Mindray Dev

## Woc JerryCodeList

* contains an OWL and a create button to create new code list. The creation just needs to specify code list ID.

CodeList的model:

```JavaScript 
[AlternativeKey] element CodeListBOID: ID;

   node CodeList[0,n] {
      element Code:NumberValue;
      element CodeText: LANGUAGEINDEPENDENT_ENCRYPTED_EXTENDED_Name;
   }
```

* click hyperlink to enter Code list TI to maintain entry
* in CodeList TI there is an ALP bound to CodeList datalist which is further bound to CodeList node in BO.
* The AddRow button just simply call List Operation "AddRow".


## Woc MainBO

* When this BO is created, you must assign a code list ID to it.
* In TI page, there is a drop down list for Status field.
* Definition

```JavaScript
element CodeListBOID: ID
association ToCodeList [0,1] to JerryCodeList using CodeListBOID;
```