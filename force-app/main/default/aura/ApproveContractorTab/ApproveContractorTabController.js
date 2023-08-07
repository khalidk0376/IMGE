({
    onloadTabs : function(component, event, helper) 
    {
        
		var stikyAttTab1 =
            {
                tabId : 'tab1',
                //divId:''
                hraderId : 'Header',
                tableId  :'exhTab',
                tabledataId : 'tableContentData',
                topmargin :355,
                leftmargin : 52,
                isTrue:true
            };
                var stikyAttTab2 =
                {
                    tabId : 'tab2',
                    //divId : ''
                    hraderId : 'myHeader',
                    tableId  :'exhTable',
                    tabledataId : 'tablecontent',
                    topmargin :355,
                    leftmargin : 52,
                    isTrue : true
            }; 
                var stikyAttTab3 =
                {
                    tabId : 'tab3',
                    ///divId:'topportion',
                    hraderId :'viewConHeader',
                    tableId  :'viewExhTable',
                    tabledataId : 'viewTableContent',
                    topmargin :355,
                    leftmargin : 52,
                    isTrue:true
            };	
                var tabAtt = [];
                tabAtt.push(stikyAttTab1); 
                tabAtt.push(stikyAttTab2);
                tabAtt.push(stikyAttTab3);	 
                //console.log('list ===' + tabAtt);
                component.set('v.tabCssAtt',tabAtt);
            },
           

            })