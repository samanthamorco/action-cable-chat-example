App.messages = App.cable.subscriptions.create('MessagesChannel', {  
  received: function(data) {
    console.log("this is getting hit");
    $("#messages").removeClass('hidden')
    return $('#messages').append(this.renderMessage(data));
  },
  renderMessage: function(data) {
    console.log("this is also getting hit");
    return "<p><b>" + data.user + ": </b>" + data.message + "</p>";
  }
});