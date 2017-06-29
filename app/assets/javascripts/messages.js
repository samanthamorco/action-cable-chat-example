App.messages = App.cable.subscriptions.create('MessagesChannel', {  
  received: function(data) {
    $("#messages-" + data.room_id).removeClass('hidden')
    return $('#messages-' + data.room_id).append(this.renderMessage(data));
  },
  renderMessage: function(data) {
    $(".form-control").val('');
    return "<p><b>" + data.user + ": </b>" + data.message + "</p>";
  }
});

$(document).on('turbolinks:load', function() {
  submitNewMessage();
});

function submitNewMessage(){
  $('textarea.form-control').keydown(function(event) {
    if (event.keyCode == 13) {
        $('[data-send="message"]').click();
        $('[data-textarea="message"]').val(" ")
        return false;
     }
  });
}
