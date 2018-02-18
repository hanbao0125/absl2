sap.ui.define([
	"sap/ui/core/UIComponent","smartControls/test/service/server"
], function(UIComponent, server) {
	"use strict";
    server.init();
	return UIComponent.extend("smartControls.Component", {
		metadata: {
			manifest: "json"
		}
	});
});