
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

// Send a question to a user's inbox via PFRelations
Parse.Cloud.define("sendQuestionToUserInbox", function(request, response) {
	var sender = request.user;
	var questionId = request.params.question;
	var recipient = request.params.friend; 
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo('FBUserID', recipient.id);
    var questionQuery = new Parse.Query("Question");
    questionQuery.get(questionId, {
        success: function(question) {
            if (question) {
                var friendQuery = new Parse.Query(Parse.User);
                friendQuery.equalTo("FBUserID", recipient.id).first().then(function(friend) {
                    if (friend) {
                        var relation = friend.relation("inbox");
                        relation.add(question);
                        friend.save(null, {
                            useMasterKey: true,
                            success: function(result) {
                                  Parse.Push.send({
                                    where: pushQuery, // Set our Installation query
                                    data: {
                                        alert: sender.getUsername() + " Quacked you a question!!"
                                    }
                                  }, {
                                    success: function() {
                                        response.success(true);
                                    },
                                    error: function(error) {
                                        response.error(error);
                                    }
                                  });
                            },
                            error: function(result, error) {
                                response.error(error);
                            }
                        });
                    } else {
                        response.error("Friend not found when trying to send question");
                    }
                });
            } else {
                response.error("Question not found when trying to send question");
            }
        },
        error: function(error) {
            response.error(error);
        }
    });
});


// Send a question to a users' inboxes via PFRelations
Parse.Cloud.define("sendQuestionToUsers", function(request, response) {
	var sender = request.user;
	var questionId = request.params.question;
	var recipients = request.params.users;

    var sentCount = 0;
    var questionQuery = new Parse.Query("Question");
    questionQuery.get(questionId, {
        success: function(question) {
            if (question) {
                for (var i = 0; i < recipients.length; i++) {
                    console.log((i + 1) + " " + recipients.length);
                    var recipient = recipients[i]; 

                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo('FBUserID', recipient.id);
                    
                    var friendQuery = new Parse.Query(Parse.User);
                    var numSent = i + 1;
                    friendQuery.equalTo("FBUserID", recipient.id).first().then(function(friend) {
                        console.log("hi");
                        if (numSent == recipients.length) {
                            console.log("success count: " + sentCount);
                        }
                        if (friend) {
                            var relation = friend.relation("inbox");
                            relation.add(question);
                            friend.save(null, {
                                useMasterKey: true,
                                success: function(result) {
                                    sentCount++;
                                    
                                    Parse.Push.send({
                                        where: pushQuery, // Set our Installation query
                                        data: {
                                            alert: sender.getUsername() + " Quacked you a question!"
                                        }
                                    }, {
                                        success: function() {
                                            console.log(true);
                                        },
                                        error: function(error) {
                                            console.log(error);
                                        }
                                    });

                                    if (numSent == recipients.length) {
                                        console.log("all done");
                                        console.log("success count: " + sentCount);
                                        response.success(true);
                                    }
                                },
                                error: function(result, error) {
                                    console.log(error);
                                    if (numSent == recipients.length) {
                                        console.log("success count: " + sentCount);
                                        response.success(true);
                                    }
                                }
                            });
                        } else {
                            console.log("Friend not found when trying to send question");
                            if (numSent == recipients.length) {
                                console.log("success count: " + sentCount);
                                response.success(true);
                            }
                        }
                    });
                }
            } else {
                console.log("Question not found when trying to send question");
            }
        },
        error: function(error) {
            console.log(error);
        }
    });
    
    
});

