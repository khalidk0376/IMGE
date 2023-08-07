({
    MAX_FILE_SIZE: 750000,    
    doInit: function(component, event, helper) {
        var canvas, ctx, flag = false,
            prevX = 0,
            currX = 0,
            prevY = 0,
            currY = 0,
            dot_flag = false;
        
        var x = "black",
            y = 2,
            w, h;
        
        var wrapper = component.find('modal-content-id-1').getElement();
        canvas = wrapper.querySelector('canvas')

        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        w = canvas.width*ratio;
        h = canvas.height*ratio;
        ctx = canvas.getContext("2d");
        //set bg
        //ctx.fillStyle = "rgb(255,255,255)";
        //ctx.fillRect(0,0,20,20);
        
        ctx.lineWidth = "5";
        ctx.strokeStyle = "green"; // Green path
        ctx.stroke(); // Draw it
        canvas.addEventListener("mousemove", function(e) {
            findxy('move', e)
        }, false);
        canvas.addEventListener("mousedown", function(e) {
            findxy('down', e)
        }, false);
        canvas.addEventListener("mouseup", function(e) {
            findxy('up', e)
        }, false);
        canvas.addEventListener("mouseout", function(e) {
            findxy('out', e)
        }, false);
        // Set up touch events for mobile, etc
        canvas.addEventListener("touchstart", function(e) {
            var touch = e.touches[0];
            var mouseEvent = new MouseEvent("mousedown", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);
            e.preventDefault();
        }, false);
        canvas.addEventListener("touchend", function(e) {
            var mouseEvent = new MouseEvent("mouseup", {});
            canvas.dispatchEvent(mouseEvent);
        }, false);
        canvas.addEventListener("touchmove", function(e) {
            var touch = e.touches[0];
            var mouseEvent = new MouseEvent("mousemove", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);
            e.preventDefault();
            
        }, false);
        
        // Get the position of a touch relative to the canvas
        function getTouchPos(canvasDom, touchEvent) {
            var rect = canvasDom.getBoundingClientRect();
            return {
                x: touchEvent.touches[0].clientX - rect.left,
                y: touchEvent.touches[0].clientY - rect.top
            };
        }
        
        function findxy(res, e) {
            var rect = canvas.getBoundingClientRect();
            if (res === 'down') {
                prevX = currX;
                prevY = currY;
                currX = e.clientX - rect.left ;//canvas.offsetLeft;
                currY = e.clientY -  rect.top;//canvas.offsetTop;
                flag = true;
                dot_flag = true;
                if (dot_flag) {
                    ctx.beginPath();
                    ctx.fillStyle = x;
                    ctx.fillRect(currX, currY, 2, 2);
                    ctx.strokeStyle = "green";
                    ctx.closePath();
                    dot_flag = false;
                }
            }
            if (res === 'up' || res === "out") {
                flag = false;
            }
            if (res === 'move') {
                if (flag) {
                    prevX = currX;
                    prevY = currY;
                    currX = e.clientX -  rect.left;
                    currY = e.clientY - rect.top;
                    draw(component, ctx);
                }
            }
        }
        
        function draw() {
            ctx.beginPath();
            ctx.moveTo(prevX, prevY);
            ctx.lineTo(currX, currY);
            ctx.strokeStyle = "black";
            ctx.lineWidth = y;
            ctx.stroke();
            ctx.closePath();
            ctx.minWidth=0.5;
            ctx.maxWidth=2;
        }
        
    },
    eraseHelper: function(component) {
        var wrapper = component.find('modal-content-id-1').getElement();
        var canvas = wrapper.querySelector('canvas')
        var ctx = canvas.getContext("2d");
        var w = canvas.width;
        var h = canvas.height;
        ctx.clearRect(0, 0, w, h);
        
    },
    saveHelper: function(component, event, closeModel, isUpdateRecord,checkData) {
        try{
            var wrapper = component.find('modal-content-id-1').getElement();
            var canvas = wrapper.querySelector('canvas')
            var vDragId = 'Signature';
            this.uploadSignature(component,vDragId,closeModel,isUpdateRecord,canvas.toDataURL("image/png"),checkData);   
        }
        catch(e)
        {
            console.log(e);
        }
    },
    uploadSignature:function(component,vDragId,closeModel,isUpdateRecord,signData,checkData){
        var fileContents = signData;
        var base64Mark = 'base64,';
        var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
        console.log('length'+base64Mark.length);
        fileContents = fileContents.substring(dataStart);
        console.log('testSigndata'+fileContents);

        component.set("v.spinner", true);
        var self = this;
        var action = component.get("c.saveSignatureResponse"); //Calling Apex class controller 'getTemplateRecrod' method
        action.setParams({
            questionId: component.get("v.questionId"),
            questionerId:component.get("v.questionerId"),
            base64Data: encodeURIComponent(fileContents)
        });
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            console.log('state'+state)
            component.set("v.spinner",true);
            if (state === "SUCCESS") {
               	var obj = JSON.parse(res.getReturnValue());
                var rspVal = obj.responseValue;
                if(obj.isSuccess==true){
                    this.showToastHelper(component,'SUCCESS : ','success','Your response has been submitted');
                     component.set("v.spinner",false);
                }else{
                    this.showToastHelper(component,'ERROR : ','error',res.getError()[0].message);
                }
                //CCEN747 **//starts with QFFieldModelCloseEvt 
                var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
                appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": vDragId, "signData":signData ,"responseValue":rspVal ,"responseId":obj.responseId ,"checkData":checkData});                
                appEvent.fire();
                //Goes to NewPreviewComponent
            } else {
                this.showToastHelper("Error :","error",res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    crudModalEvent: function(component, event, closeModel, isUpdateRecord ,checkData) {
        var vDragId = 'Signature';
        var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
        appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": vDragId, "signData":"" ,"checkImageData":checkData});
        appEvent.fire();
    },
    showToastHelper:function(component,title,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent!=undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                duration: '5000',
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.msgbody",message);
            component.set("v.msgtype",type);
            window.setTimeout($A.getCallback(function() {
                component.set("v.msgbody",'');
                component.set("v.msgtype",'');
            }), 5000);
        }
    }

})