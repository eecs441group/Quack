
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


// pushQuestions is called on a new question being saved, and is pushed to 
// all friends of the user
Parse.Cloud.define("sendPushToUser", function(request, response) {
	var senderUser = request.user;
	var recipientUserId = request.params.recipientId;
	var message = senderUser + "quacked you a question!";

	// Validate the message text.
	// For example make sure it is under 140 characters
	if (message.length > 140) {
	// Truncate and add a ...
		message = message.substring(0, 137) + "...";
	}

	// Send the push.
	// Find devices associated with the recipient user
	var recipientUser = new Parse.User();
	recipientUser.id = recipientUserId;
	var pushQuery = new Parse.Query(Parse.Installation);
	pushQuery.equalTo("user", recipientUser);

	// Send the push notification to results of the query
	Parse.Push.send({
	where: pushQuery,
	data: {
		alert: message
	}
	}).then(function() {
		response.success("Push was sent successfully.")
	}, function(error) {
		response.error("Push failed to send with error: " + error.message);
	});
});