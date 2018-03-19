import ABSL;

import AP.CRM.Global;

import AP.Common.GDT;

var ticketReq:Ticket.MaintainBundle.Request;
var SerReq : Ticket.MaintainBundle.Request.ServiceRequestBundleMaintainRequest2_sync.ServiceRequest ;
var SrvReqItem : Ticket.MaintainBundle.Request.ServiceRequestBundleMaintainRequest2_sync.ServiceRequest.Item;

SerReq.actionCode = "06";
SerReq.ID = this.ID;

 var counter = 0;
 while(counter < 500)
 {
	SrvReqItem.actionCode = "01"; //Create Item
	SrvReqItem.Description.content = "Add item from WS" ;
	SrvReqItem.ProductID.content = "P120100";
	SrvReqItem.RequestedQuantity.content = 1.0;
	SrvReqItem.RequestedQuantity.unitCode = "EA";
	SrvReqItem.UserServiceTransactionProcessingTypeCode = "SRP0";
	SerReq.Item.Add(SrvReqItem);
	counter = counter + 1;
}
ticketReq.ServiceRequestBundleMaintainRequest2_sync.ServiceRequest.Add(SerReq);

var response = Library::Ticket.MaintainBundle(ticketReq,"","Ticket");


