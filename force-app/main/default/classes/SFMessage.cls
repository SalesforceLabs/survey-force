public without sharing class SFMessage {
	public String message { get; set; }
	public String severity { get; set; }
	public Boolean isMessage { get; set; }

	public void setMessage(String message, String severity) {
		setMessage(message, severity, true);
	}

	public void setMessage(String message, String severity, Boolean isMessage) {
		this.message = message;
		this.severity = severity;
		this.isMessage = isMessage;
	}
}