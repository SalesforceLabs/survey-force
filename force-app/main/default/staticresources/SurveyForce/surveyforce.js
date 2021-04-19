//For displaying tabs in SurveyManagerPage.page
function showTab(tabIndex){
    window.location.hash = tabIndex;
    //Deactive existing tab
    $('li.slds-tabs_scoped__item').removeClass('slds-is-active');

    //Hide active tab content
    $('div.slds-tabs_scoped__content').removeClass('slds-show');

    //Hide active tab content
    $('div.slds-tabs_scoped__content').addClass('slds-hide');
	$("#tab-scoped-" + tabIndex).removeClass("slds-hide");

    //Activate actual tab
    $('#tab-scoped-li-' + tabIndex).addClass('slds-is-active');
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
    $('#' + dialogId+'Backdrop').removeClass('slds-backdrop_hide');


    $('#' + dialogId).addClass('slds-fade-in-open');
    $('#' + dialogId+'Backdrop').addClass('slds-backdrop_open');
}
function closeDialog(dialogId){
    $('#' + dialogId).removeClass('slds-fade-in-open');
    $('#' + dialogId+'Backdrop').removeClass('slds-backdrop_open');


    $('#' + dialogId).addClass('slds-fade-in-hide');
    $('#' + dialogId+'Backdrop').addClass('slds-backdrop_hide');
}

function adjustIframeHeight(frameId){
    $("[Id$="+frameId + "]").load(function() {
        $(this).height( $(this).contents().find("body").height() );
    });
}