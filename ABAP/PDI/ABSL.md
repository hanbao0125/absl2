* this.BilltoParty.IsSet()

this.BilltoParty.IsSet():References to business object nodes (associations) have to be checked using the IsSet() method before accessing them. If a reference that is not set is accessed, the system will terminate the program.

# Query Related

```abap
import AP.Common.GDT;
import AP.CRM.Global;
var SalesOrderquery = SalesOrder.QueryByElements;
var queryParameter = SalesOrderquery.CreateSelectionParams();
var queryResult;
queryParameter.Add(SalesOrderquery.ID.Content,"I", "EQ","1686");
queryResult = SalesOrderquery.Execute(queryParameter);
foreach( item in queryResult )
     item.ext_test_for_lock = "change by Service Order";
```

# collection

import ABSL;
import AP.Common.GDT

```abap
var mycollection : collectionof SalesOrder.BuyerID; // internal table
```

# element

var mycollection: collectionof SalesOrder.BuyerID;
var result: collectionof SalesOrder.BuyerID;

var item_one: elementof SalresOrder.BuyerID;
var item_two: elementof SalresOrder.BuyerID;
var collection: collectionof SalesOrder.SystemAdministrativeData;

item_one.content = "A";
mycollection.Add( item_one);

