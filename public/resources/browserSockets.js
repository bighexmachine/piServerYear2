var socket = new WebSocket("ws://192.168.0.1:3000/");
var queuePos = -1;

socket.onopen = function() {
    socket.send("askServerForAccessToAPI");
};

socket.onmessage = function(evt) {
    var received_msg = evt.data;
    console.log("Message is received: " + received_msg);
    switch(evt.data) {
        case "denied":
            console.log("denied access to api");
            updateQueueUI(queuePos);
            break;
        case "accessAPISuccess":
            queuePos = 1;
            console.log("changed to 1");
            updateQueueUI(queuePos);
            break;
        case "moveUpQueue":
            queuePos = queuePos - 1;
            console.log("moved up queue");
            updateQueueUI(queuePos);
            break;
        case "leaveQueueSuccess":
            queuePos = -1;
            updateQueueUI(queuePos);
            break;
    }
};


function askServerForAccessToAPI(callback) {
    socket.send("requestToAccessAPI");
    if(queuePos === 1) {
        callback();
    }
}

function leaveQueue(toBack) {
    socket.send("leaveQueue");
}