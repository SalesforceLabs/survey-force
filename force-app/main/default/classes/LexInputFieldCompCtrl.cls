public with sharing class LexInputFieldCompCtrl {
	/**
	 * The object name for this Visualforce component
	 */
	public SObject inputObject { get; set; }
	/**
	 * The field name for this component
	 */
	public String fieldName { get; set; }

	/**
	 * Can the user update this field?
	 * @return `Boolean` is the field read-only?
	 */
	public Boolean isReadOnly {
		get {
			return !getFieldDescribe().isUpdateable();
		}
	}

	/**
	 * Get the Field Type. We only check for TextArea, Picklist, MultiPicklist, Checkbox, Date/DateTime, Lookup, and we lump all others into generic Input
	 * @return String of Field Type
	 */
	public String fieldType {
		get {
			DisplayType dispType = getFieldDescribe().getType();

			switch on dispType {
				when TextArea {
					return 'TextArea';
				}
				when Picklist {
					return 'Picklist';
				}
				when MultiPicklist {
					return 'MultiPicklist';
				}
				when Boolean {
					return 'Checkbox';
				}
				when Date, DateTime {
					return 'DateTime';
				}
				when reference {
					return 'Lookup';
				}
				when else {
					return 'Input';
				}
			}
		}
	}

	/**
	 * Check if we are dealing with one of the field types we group into generic input
	 * <br>String, Currency, Email, Double, Integer, Percent, URL, Phone
	 * @return   true if the field is one of those types
	 */
	public Boolean isInput {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (
				dispType == Schema.DisplayType.String ||
				dispType == Schema.DisplayType.Currency ||
				dispType == Schema.DisplayType.Email ||
				dispType == Schema.DisplayType.Double ||
				dispType == Schema.DisplayType.Integer ||
				dispType == Schema.DisplayType.Percent ||
				dispType == Schema.DisplayType.URL ||
				dispType == Schema.DisplayType.Phone
			) {
				return true;
			} else {
				return false;
			}
		}
	}

	/**
	 * Is this a text area? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isTextarea {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.TextArea) {
				return true;
			} else {
				return false;
			}
		}
	}
	/**
	 * Is this a picklist? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isPicklist {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.Picklist) {
				return true;
			} else {
				return false;
			}
		}
	}
	/**
	 * Is this a multi-select picklist? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isMultiPicklist {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.MultiPicklist) {
				return true;
			} else {
				return false;
			}
		}
	}
	/**
	 * Is this a checkbox? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isCheckbox {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.Boolean) {
				return true;
			} else {
				return false;
			}
		}
	}
	/**
	 * Is this a Date or DateTime field? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isDateTime {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
				return true;
			} else {
				return false;
			}
		}
	}
	/**
	 * Is this a lookup? (Currently unused in Visualforce)
	 * @return true/false
	 */
	public Boolean isLookup {
		get {
			DisplayType dispType = getFieldDescribe().getType();
			if (dispType == Schema.DisplayType.reference) {
				return true;
			} else {
				return false;
			}
		}
	}

	/**
	 * Memoize the field for this component so we avoid too many describe calls
	 */
	private Schema.SObjectField componentField;

	/**
	 * Check if we have already done the describe call, to avoid doing unnecessary calls
	 *
	 * @return  `Schema.SObjectField` The Schema field for the given object/field
	 * @see getFieldDescribe
	 */
	public Schema.SObjectField getSField() {
		if (componentField != null) {
			return componentField;
		}
		if (inputObject != null && componentField == null) {
			componentField = inputObject.getSObjectType().getDescribe().fields.getMap().get(fieldName);
			return componentField;
		} else {
			return null;
		}
	}
	/**
	 * Memoize the describe field result for this component so we avoid too many describe calls
	 */
	private Schema.DescribeFieldResult componentFieldDescribe;

	/**
	 * Check if we have already called getSField.getDescribe, which does a describe call. This saves on extra describe calls
	 *
	 * @return  `Schema.DescribeFieldResult` The Schema field describe result for the given object/field
	 * @see getSField
	 */
	public Schema.DescribeFieldResult getFieldDescribe() {
		if (componentFieldDescribe != null) {
			return componentFieldDescribe;
		}
		Schema.SObjectField sf = getSField();
		if (sf != null) {
			componentFieldDescribe = sf.getDescribe();
			return componentFieldDescribe;
		} else {
			return null;
		}
	}

	//
	public String objectName {
		get {
			if (inputObject != null) {
				return inputObject.getSObjectType().getDescribe().getName();
			} else {
				return '';
			}
		}
	}
}