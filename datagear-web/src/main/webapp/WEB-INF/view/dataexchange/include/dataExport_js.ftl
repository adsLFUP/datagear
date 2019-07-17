<#--
导出公用片段

String dataExchangeId 数据交换ID
String dataExchangeChannelId 数据交换cometd通道ID

依赖：
dataExchange_js.ftl

-->
<script type="text/javascript">
(function(po)
{
	po.dataExchangeChannelId = "${dataExchangeChannelId}";
	
	po.addSubDataExchange = function()
	{
		var rowData = {subDataExchangeId : po.nextSubDataExchangeId(), query : "", fileName : "", status : ""};
		po.postBuildSubDataExchange(rowData);
		po.addRowData(rowData);
	};
	
	po.buildSubDataExchangesForTables = function(tableNames)
	{
		var datas = [];
		
		for(var i=0; i< tableNames.length; i++)
		{
			var data = {subDataExchangeId : po.nextSubDataExchangeId(), query : tableNames[i],
					fileName : po.toExportFileName(tableNames[i]), status : ""};
			
			po.postBuildSubDataExchange(data, tableNames[i]);
			
			datas.push(data);
		}
		
		return datas;
	};
	
	po.postBuildSubDataExchange = function(subDataExchange, tableName){};
	
	po.addAllTable = function()
	{
		if(po._addAllTableDoing)
			return;
		
		po._addAllTableDoing = true;
		
		$.ajax(
		{
			url : "${contextPath}/dataexchange/" + po.schemaId +"/getAllTableNames",
			success : function(tableNames)
			{
				if(!tableNames)
					return;
				
				var rowDatas = po.buildSubDataExchangesForTables(tableNames);
				po.addRowData(rowDatas);
			},
			complete : function()
			{
				po._addAllTableDoing = false;
			}
		});
	};
	
	po.toExportFileName = function(tableName)
	{
		return tableName;
	};
	
	po.handleSubDataExchangeStatus = function(subDataExchangeId, status, message)
	{
		var type = (message ? message.type : "");
		
		if("SubSuccessWithCount" == type)
		{
			if(!message.failCount || message.failCount == 0)
			{
				var spanIndex = status.indexOf("<span");
				if(spanIndex > 0)
					status = status.substring(0, spanIndex);
			}
			
			status += "<span class='exchange-result-icon exchange-download-icon' title='"+$.escapeHtml("<@spring.message code='download' />")+"' subDataExchangeId='"+$.escapeHtml(message.subDataExchangeId)+"' >"
				+"<span class='ui-icon ui-icon-circle-arrow-s'></span></span>";
		}
		
		return status;
	};
	
	po.dataExportTableColumns =
	[
		{
			title : "<@spring.message code='dataExport.tableNameOrQueryStatement' />",
			data : "query",
			render : function(data, type, row, meta)
			{
				if(!data)
					data = "";
				
				return "<input type='hidden' name='subDataExchangeIds' value='"+$.escapeHtml(row.subDataExchangeId)+"' />"
						+ "<input type='text' name='queries' value='"+$.escapeHtml(data)+"' class='query-input input-in-table ui-widget ui-widget-content' style='width:90%' />";
			},
			defaultContent: "",
			width : "50%",
		},
		{
			title : "<@spring.message code='dataExport.exportFileName' />",
			data : "fileName",
			render : function(data, type, row, meta)
			{
				if(!data)
					data = "";
				
				return "<input type='text' name='fileNames' value='"+$.escapeHtml(data)+"' class='file-name-input input-in-table ui-widget ui-widget-content' style='width:90%' />";
			},
			defaultContent: "",
			width : "20%"
		},
		{
			title : $.buildDataTablesColumnTitleWithTip("<@spring.message code='dataExport.exportProgress' />", "<@spring.message code='dataExport.exportStatusWithSuccessFail' />"),
			data : "status",
			render : function(data, type, row, meta)
			{
				if(!data)
					return "<@spring.message code='dataExchange.exchangeStatus.Unstart' />";
				else
					return data;
			},
			defaultContent: "",
			width : "30%"
		}
	];
	
	po.initDataExportSteps = function()
	{
		po.element(".form-content").steps(
		{
			headerTag: "h3",
			bodyTag: "div",
			onStepChanged : function(event, currentIndex, priorIndex)
			{
				if(currentIndex == 1)
					po.adjustDataTable();
			},
			onFinished : function(event, currentIndex)
			{
				po.element("#${pageId}-form").submit();
			},
			labels:
			{
				previous: "<@spring.message code='wizard.previous' />",
				next: "<@spring.message code='wizard.next' />",
				finish: "<@spring.message code='export' />"
			}
		});
		
		po.element("#${pageId}-form .wizard .actions ul li:eq(2)").addClass("page-status-aware-enable edit-status-enable");
	};
	
	po.initDataExportUIs = function()
	{
		$.initButtons(po.element());
		po.element("#${pageId}-nullForIllegalColumnValue").buttonset();
		po.element("#${pageId}-add-group-select").selectmenu(
		{
			classes : {"ui-selectmenu-button": "ui-button-icon-only ui-corner-right"},
			select : function(event, ui)
			{
				if(ui.item.value == "addAll")
					po.addAllTable();
			}
		});
		po.element("select[name='fileEncoding']").selectmenu({ appendTo : po.element(), classes : { "ui-selectmenu-menu" : "file-encoding-selectmenu-menu" } });
		po.element("#${pageId}-add-group").controlgroup();
		
		po.element("#${pageId}-nullForIllegalColumnValue-1").click();
	};
	
	po.initDataExportDataTable = function()
	{
		po.expectedResizeDataTableElements = [po.table()[0]];
		
		var tableSettings = po.buildDataTableSettingsLocal(po.dataExportTableColumns, [], {"order": []});
		po.initDataTable(tableSettings);
		po.bindResizeDataTable();
	};
	
	po.initDataExportActions = function()
	{
		po.element(".table-add-item-button").click(function()
		{
			po.addSubDataExchange();
			
			//滚动到底部
			var $dataTableParent = po.dataTableParent();
			$dataTableParent.scrollTop($dataTableParent.prop("scrollHeight"));
		});
		
		po.element(".table-delete-item-button").click(function()
		{
			po.executeOnSelects(function(rowDatas, rowIndexes)
			{
				po.deleteRow(rowIndexes);
			});
		});
		
		po.element(".table-cancel-export-button").click(function()
		{
			po.cancelSelectedSubDataExchange();
		});
		
		po.element(".table-download-all-button").click(function()
		{
			po.open("${contextPath}/dataexchange/" + po.schemaId +"/export/downloadAll",
			{
				target : "_file",
				data :
				{
					dataExchangeId : po.dataExchangeId
				}
			});
		});
		
		po.table().on("click", ".input-in-table", function(event)
		{
			//阻止行选中
			event.stopPropagation();
		});
		
		po.table().on("click", ".exchange-result-icon", function(event)
		{
			//阻止行选中
			event.stopPropagation();
			
			var $this = $(this);
			
			if($this.hasClass("exchange-error-icon"))
			{
				var subDataExchangeId = $this.attr("subDataExchangeId");
				po.viewSubDataExchangeDetailLog(subDataExchangeId);
			}
			else if($this.hasClass("exchange-download-icon"))
			{
				var subDataExchangeId = $this.attr("subDataExchangeId");
				var fileName = (po.subDataExchangeFileNameMap ? po.subDataExchangeFileNameMap[subDataExchangeId] : null);
				
				if(fileName)
				{
					po.open("${contextPath}/dataexchange/" + po.schemaId +"/export/download",
					{
						target : "_file",
						data :
						{
							dataExchangeId : po.dataExchangeId,
							fileName : fileName
						}
					});
				}
			}
		});
		
		po.element(".restart-button").click(function()
		{
			po.updateDataExchangePageStatus("edit");
		});
		
		po.element("#${pageId}-form").submit(function()
		{
			po.resetAllSubDataExchangeStatus();
			
			po.cometdExecuteAfterSubscribe(po.dataExchangeChannelId,
			function()
			{
				po.element("#${pageId}-form").ajaxSubmit(
				{
					success: function(data)
					{
						po.subDataExchangeFileNameMap = data.data;
						
						if(!po.isDataExchangePageStatus("finish"))
							po.updateDataExchangePageStatus("exchange");
					}
				});
			},
			function(message)
			{
				po.handleDataExchangeCometdMessage(message);
			});
			
			return false;
		});
	};
})
(${pageId});
</script>
</body>
</html>
