
//Convert standard checkboxes to Lightning Design System
//This is because it's easier to use <apex:selectOptions> here but no easy way to change those to LDS 
function convertCheckBoxToLDS() {
    var Row = document.getElementsByClassName("convertToLDS");
    for (var k = 0; k < Row.length; k++) {
        var colTds = Row[k].getElementsByTagName("td");
        for (var i = 0; i < colTds.length; i++) {
            var inrHtml = colTds[i].innerHTML;
            var chkId = inrHtml.substring(inrHtml.indexOf("id=") + 4, inrHtml.indexOf("\"", inrHtml.indexOf("id=") + 4));
            var chkBx = inrHtml.substring(inrHtml.indexOf("<input"), inrHtml.indexOf(">") + 1);
            var chkLable = colTds[i].getElementsByTagName("label")[0].textContent;
            var typeOfInput = colTds[i].getElementsByTagName("input")[0].getAttribute("type");
            var newChkBox = '<label class="slds-' + typeOfInput + '" for="' + chkId + '">' + chkBx +
                    '<span class="slds-' + typeOfInput + '--faux"></span>' +
                    '<span class="slds-form-element__label">' + chkLable + '</span>' +
                    '</label>';
            colTds[i].innerHTML = newChkBox;
        }
    }
}

//For displaying tabs in SurveyManagerPage.page
function showTab(tabIndex){
    window.location.hash = tabIndex;
    //Deactive existing tab
    $('li.slds-tabs--scoped__item').removeClass('slds-active');

    //Hide active tab content
    $('div.slds-tabs--scoped__content').removeClass('slds-show');

    //Hide active tab content
    $('div.slds-tabs--scoped__content').addClass('slds-hide');

    //Activate actual tab
    $('#tab-scoped-li-' + tabIndex).addClass('slds-active');
    $('#tab-scoped-' + tabIndex).addClass('slds-show');

    return false
}

//Send Users to a URL
//If in one.app then use "e.force:navigateToURL"; otherwise use window.location.href
function goToURL(url, newWindow){
    if(typeof(newWindow) == 'undefined' || newWindow == false) {
    	if(typeof($A) != 'undefined' && typeof($A.get("e.force:navigateToURL")) != 'undefined'){
	        var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": purl
            });
            urlEvent.fire();
        } else {
            window.location.href = url;
        }
    }else{
        window.open(url);
    }
    return false;
}


function openDialog(dialogId){
    $('#' + dialogId).removeClass('slds-fade-in-hide');
    $('#' + dialogId+'Backdrop').removeClass('slds-backdrop--hide');


    $('#' + dialogId).addClass('slds-fade-in-open');
    $('#' + dialogId+'Backdrop').addClass('slds-backdrop--open');
}
function closeDialog(dialogId){
    $('#' + dialogId).removeClass('slds-fade-in-open');
    $('#' + dialogId+'Backdrop').removeClass('slds-backdrop--open');


    $('#' + dialogId).addClass('slds-fade-in-hide');
    $('#' + dialogId+'Backdrop').addClass('slds-backdrop--hide');
}

function adjustIframeHeight(frameId){
    $("#"+frameId).load(function() {
        $(this).height( $(this).contents().find("body").height() );
    });
}

function overridePageMessages(){
    var textureEffect = '';
    //Uncomment below line for texture effect on page messages
    //textureEffect = 'slds-theme--alert-texture';

    $('.warningM3').addClass('slds-notify slds-notify--toast slds-theme--warning customMessage '+textureEffect);
    $('.confirmM3').addClass('slds-notify slds-notify--alert slds-theme--success  customMessage '+textureEffect);
    $('.errorM3').addClass('slds-notify slds-notify--alert slds-theme--error customMessage '+textureEffect);
    $('.infoM3').addClass('slds-notify slds-notify--toast customMessage '+textureEffect);

    $('.errorM3').removeClass('errorM3');
    $('.confirmM3').removeClass('confirmM3');
    $('.infoM3').removeClass('infoM3');
    $('.warningM3').removeClass('warningM3');
}