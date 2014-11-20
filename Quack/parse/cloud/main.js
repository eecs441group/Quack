// Send a push notification to a s
var sendPushToUser = function(request) {
    var sender = request.sender;
    var recipient = request.recipient;

    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo('FBUserID', recipient.id);

    Parse.Push.send({
        where: pushQuery, // Set our Installation query
        data: {
            alert: sender.getUsername() + " Quacked you a question!"
        }
    }, {
        success: function() {
            console.log("push success for " + recipient.name);
        },
        error: function(error) {
            console.log("push error: " + error);
        }
    });
}

// Send a question to a single user's inbox
var sendQuestionToUser = function(request, response) {
    var questionId = request.questionId;
    var recipient = request.recipient; 

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
                                console.log("save successful");
                                response.success(true);
                            },
                            error: function(result, error) {
                                console.log("save failed");
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
};

Parse.Cloud.define("sendQuestion", function(request, response) {
    var recipients = request.params.users;
    for (var i = 0; i < recipients.length; ++i) {
        var index = i;
        var params = {
            sender: request.user,
            questionId: request.params.question,
            recipient: recipients[i]
        }

        sendQuestionToUser(params, {
            success: function(sendResponse) {
                // call response callback when we're finished with the last
                // recipient
                if (index >= recipients.length - 1) {
                    console.log("all done");
                    response.success(true);
                }
            },
            error: function(sendResponse) {
                if (index >= recipients.length - 1) {
                    if (sendResponse == "Friend not found when trying to send question"){
                        // if friend isn't found in database, ignore this error
                        // for now
                        response.success(true);
                    } else {
                        response.error(sendResponse);
                    }
                }
            }
        });

        // send push to user asynchronously, do not wait for callback (for now)
        sendPushToUser(params);
    }
});
