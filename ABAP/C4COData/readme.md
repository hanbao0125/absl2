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
APCRM_OPP_INSTALLED_OBJ