public with sharing class LexInputFieldCompCtrl {
    public LexInputFieldCompCtrl() {

    }
    public SObject inputObject { get; set; }
    public String fieldName { get; set; }

    public Boolean isReadOnly {
        get {
            return !getFieldDescribe().isUpdateable();
        }
    }


    public Boolean isInput {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Currency ||dispType == Schema.DisplayType.Email ||  dispType == Schema.DisplayType.Double ||dispType == Schema.DisplayType.Integer ||dispType == Schema.DisplayType.Percent ||dispType == Schema.DisplayType.URL ||dispType == Schema.DisplayType.Phone)
                return true;
            else
                return false;
        }
    }

    public Boolean isTextarea {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.TextArea)
                return true;
            else
                    return false;
        }
    }

    public Boolean isPicklist {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.Picklist)
                return true;
            else
                    return false;
        }
    }


    public Boolean isMultiPicklist {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.MultiPicklist)
                return true;
            else
                    return false;
        }
    }

    public Boolean isCheckbox {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.Boolean)
                return true;
            else
                    return false;
        }
    }

    public Boolean isDatetime {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.Date ||
                    dispType == Schema.DisplayType.Datetime)
                return true;
            else
                    return false;
        }
    }

    public Boolean isLookup {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            if (dispType == Schema.DisplayType.reference)
                return true;
            else
                    return false;
        }
    }

    public SObjectField getSField() {
        if (inputObject != null)
            return inputObject.getSObjectType().getDescribe().fields.getMap().get(fieldName);
        else
                return null;
    }

    public DescribeFieldResult getFieldDescribe() {
        SObjectField sf = getSField();
        if (sf != null)
            return sf.getDescribe();
        else
                return null;
    }

    //
    public String objectName {
        get {
            if (inputObject != null)
                return inputObject.getSObjectType().getDescribe().getName();
            else
                    return '';
        }
    }
}