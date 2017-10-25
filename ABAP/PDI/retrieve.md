```Javascript
var SalesOrderID : elementsof SalesOrder.ID; 
SalesOrderID.content = "12";
SalesOrder.Retrieve( SalesOrderID );
```
Corresponding ABAP code snippet:
```abap
DATA SAP_LINE_OF_COLLECTION_10 TYPE REF TO IF_APCRM_CTD_TEMPLATE=>TY_ROOT.
 SAP_LINE_OF_COLLECTION_10 ?= RETRIEVE_SINGLE(
  IV_SOURCE_BO_NAME = 'SALES_ORDER'
  IV_SOURCE_NODE_NAME = 'ROOT'
  IV_SOURCE_KEY_TYPE_NAME = 'APC_S_BTD_ID'
  IS_SOURCE_KEY = SalesOrderID ).
```