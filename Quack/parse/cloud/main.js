
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

Parse.Cloud.define("sendQuestionToAllUsers", function(request, response) {
	var sender = request.user;
	var question = request.params.question;
	var recipients = request.params.friends; 

	for (i = 0; i < 1; i++) {
		var query = new Parse.Query(Parse.User);
		query.equalTo("FBUserID", recipients[i].id).first()
			.then(function(results){
				results.add("userInbox",question);
				//response.success(results);
			});
	}

	//response.success("succeded");
});

Parse.Cloud.define("sendQuestionToUser", function(request, response) {
    var sender = request.user;
    var question = request.params.question;
    var recipient = request.params.friend; 
    var query = new Parse.Query(Parse.User);
    query.equalTo("FBUserID", recipient.id).first().then(function(result){
        if (result){
            result.add("userInbox",question);
            result.save(null, { useMasterKey: true });
            response.success(result);
        }
    });
    response.success("succeded");
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

