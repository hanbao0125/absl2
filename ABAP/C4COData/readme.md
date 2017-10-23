# Initial uploaded on 2017-10-3 10:49PM

Change log: Business flexibility - change log

Registered Product  is made up of 2 Business Objects.

* InstallationPoint (http://sap.com/xi/AP/FO/IBase/Global)
* IndividualProduct ( http://sap.com/xi/AP/FO/ProductDataMaintenance/Global)

The view Registered Product is seen in 2 Work Centers - Products and Installed Base.
[Useful document](https://archive.sap.com/documents/docs/DOC-68151)

Scoping: Communication and Information Exchange->Integration with External Applications and Solutions->Integration into Sales, Service, and Marketing Processes->Group: Sales Quotes End of the navigation path.

Sales quote processing is used to offer products to customers according to specific terms with fixed conditions.The seller is bound by the sales quote for a specific period of time. The sales quote is usually created by a sales representative of the company.

Business partners is the collective term for all the companies and people you interact with in your business, and includes accounts, contacts, partners, and employees. When you create a document, you can designate a business partner as an involved party and assign them a role.

[Sales Quote SAP help](https://cp.hana.ondemand.com/dps/d/preview/6029d1035487452d858f1cdf229f4af1/1508/en-US/frameset.html?187da78e763d1014add6efccbd6607e6.html)

[Create sales quote from opportunity in C4C - possible?](https://archive.sap.com/discussions/thread/3783575)

* We can only create an ERP sales quote or order from an opportunity.
* we could create a sales quote/order in C4C without any predecessors.

How do you change action options? I only have that options. ?!

[Opportunity SAP help](https://help.sap.com/viewer/637db7a0d01e47009d9420e9a927c571/1708/en-US/7c26aed20dda43adabb14c5b281b3963.html#loio7c26aed20dda43adabb14c5b281b3963)

Create an Opportunity from a Registered Product - how?!

>
In SAP Hybris Cloud for Customer, you can create opportunities from one or more registered products using the Opportunities tab of a registered product or from the Registered Products tab when selecting multiple products. This feature allows you to create opportunities more easily when increasing your line of business from existing products. From the Registered Products tab, you can create opportunities and choose one or multiple registered products as detailed below.

This feature is only available if the scoping question in Opportunity is turned on here:  Business Configuration->Scoping->Questions->Sales->New Business->Opportunity->Do you want to enable users to capture registered products in opportunities? 

Registered product is in Service scoping? yes 2017-10-5 6:07PM
create with reference does not work in C4C!
data flow: sales quote to sales order -> at least in BYD!
Sales Quote是Sales scenario里的。

/BYD_COD/ServiceOnDemand/RegisteredProduct/UI/COD_Registered_Product_TI
只教怎么做，没说出问题怎么办。。
APCRM_OPP_INSTALLED_OBJ is a business feature.

NavigationBar.prototype.addItem

In A6P, Opportunity tab is navigationItem4

Whether a change transaction can be used for extensibility can be found out in tab properties->Extensibility->Anchors. Each anchor containing a reference field shall be extensible.  

The path e.g. from the Controller Attribute to the BO Node field can be determined easily in case model information is available e.g. in case of a BSA or FSI model, or it can be more complicated if there is coding in between and no model information available. In those cases where the path information cannot be derived from a model, explicit mapping has to be maintained using the newly introduced MDRS meta object Extensibility Mapping to close the model gap. 

Extensibility Mapping instances are relevant only for those nodes with Reference Field definitions and there for any involved Controller Object when no BSA model is in place or when BSA-based ECO also contains coded paths which are extensibility-relevant, i.e. BSA indicator Dedicated is set. 就是一些metadata.

Regarding section group and list we distinguish between "personalization" and "field extensibility" anchors. Pure personalization anchors do not have an assignment to a reference field. As soon as reference field information is maintained in the anchor it can be regarded as personalization and field extensibility anchor. Personalization anchors have already been generated for all existing section groups and lists of all UI models via mass change report. For new UI section groups and lists personalization anchors are automatically created in the UI designer.

Technically a UI Anchor
* Has an own, release stable name
* Points to a field in the data model of the UI
* Points to a reference field in the ABAP backend\

# tenant specific

The problem is not the isolation of data but of metadata. The table has this extra field in every client. This means that no tenant on this system can be moved to another system on which this add-on is not installed.

* /EXT/CUS_DELETE_FIELD_BY_LABEL
* /EXT/CUS_DELETE_FIELDS_BY_NODE

cl_oberon_fm_white_list=>verify_fm_in_white_list

My custom BO action: YT42LIMGY_CL_T9DB8F8822A14E8B0=>ACTION_CALCULATE line 166
Custom query developed in Cloud studio is implemented by TREX. 

# UI

* note in TI is implemented by span ( display mode). In span.textContent, no line break found.

# OVS

After I switch to Customer OVS, I even could not see Customer data in OWL!! 10/12/2017

CX_OBERON_CONTROLLER_EXCEPTION. It seems I didn't find the OVS query. CL_OBERON_MODEL_PARSER

* error 1: Query input paramter /Root/SearchParameters1/InternalID bound to a BO node attribute

* error 2: Exception Message: XRepositoryException (4)Invalid model: query binding is missing in data field /Root/Items/FormattedName
SADL View generation failed

# Extensibility

* If you create an embedded component and you would like that customer can add their own extension fields via key user tool adaptation mode into this embedded component, this is not possible.

# 2017-10-13

I cannot save rule created in KUT!! 烟草系统不行。203可以。
rule visibility issue: https://youtu.be/Dv_cNrVFMzY

# 2017-10-16

employee creation failed in 203. Partner代码引起。
Shoud always activate Library first!

Why mapping is needed? proxy structure can be deeply nested but database structure should be completely flat.
CSP: Core Service Provider - used as part of all terms which refer to a real implementation model ( CDF,
BOPF, UEO ... ).

MR didn't use Service scenario.

AdvancedListPane needs manual refresh to see the data on initialization phase.

# 2017-10-20

1. $YT42LIMGY_PRX dropdown list联动的research到此为止 - this morning terminated

In 203, callstack is very clean: BusinessPartnerRelationship.BeforeSave, onSave validation.

why 203 does not have determination time = F?

918: me->execute_dummy_update line 329 class CL_BUPA_ERP_REPL_OUT_EXT 203 not called!!!

/EXT/CL_CUS_RT_CORE_SRV

cross-DU queries are supported in PDI, retrieve / retrieve by association not. 

EXF: create FE on root and an AfterModify determination to copy the field from Root FE to item standard field. and when fields. When changes are done on DO, the determination is called as well.  

why manual extension has issue in multi-tenant environment: 

The problem is not the isolation of data but of **metadata**. The table has this extra field in **every client**. This means that 
# no tenant on this system can be moved to another system on which this add-on is not installed.

this also applied to those tenants that are not using this add-on.

Extension field's type reused in Web Service message type

# 2017-10-23

1. 203 tenant上这个interface不是active状态，所以behavior和918不一样
2. Administrator->Input and Output->Integration->Communication Arrangement
3. [Integration with CRM](https://rapid.sap.com/bp/#/RDS_CFC_ERP)
4. Prerequisite in PI: You have a user assigned to the LcrInstanceWriterLD role. See [SAP help](https://help.sap.com/saphelp_nw70/helpdata/en/87/7277e8fba34421a45d97a41ec27381/frameset.htm).
Create an user in CRM system: Check SAP Note 1956819 for the authorization role to be assigned to the below user.
5. In PI, create SM59 destination to CRM.
The technical system of type AS ABAP for SAP CRM system should be created.
In C4C Administator->Input and output management, enter the information about the backend CRM system. It is important to note that all the
information is related to the CRM system, logical system name, SAP client, and so on , with
the exception of the host which, should be the hostname of how the SAP PI on-premise
system will be accessed. Also make sure that you check the option of **SAP Business Suite**.
6. Run this report in CRM system: CRMPCD_CUST_EXCHANGE