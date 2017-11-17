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

proxy name: **YT42LIMGY_MABO3E22777E9DB70018**


```JavaScript
element CodeListBOID: ID
association ToCodeList [0,1] to JerryCodeList using CodeListBOID;
element OrderStatus: NumberValue;
```

In AfterModify, fill this association:

```JavaScript
if( !this.CodeListBOID.IsInitial() && !this.ToCodeList.IsSet() ){
	var codeListQuery = JerryCodeList.QueryByElements;
	var para = codeListQuery.CreateSelectionParams();
	para.Add( codeListQuery.CodeListBOID, "I", "EQ", this.CodeListBOID);
	var result = codeListQuery.Execute(para);
	this.ToCodeList	= result.GetFirst();
	this.OrderName = "AFTER MODIDY" + this.ToCodeList.CodeListBOID;
}
```

* DropDown list的value绑在某个具体的number field上，但是List的code 和text是绑在一个DataList的code和text上。OnValueChanged的事件也不是在Designer里维护，而是在DataModel tab里维护。