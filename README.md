# Installing Action Cable

## About
This README is going to be about how to install Action Cable to get a live chat feature working.

The master branch has a basic chat feature set up. There's a User model, set up with Devise, a Room model that creates chat rooms, and a Message model that holds the message content. It works with just Rails and triggers a page refresh every time a message is sent. The purpose of this tutorial is to use Action Cable, which will display the message instantly without a page refresh. While this can be done in JS, Action Cable takes it one step further. If someone on a different session is looking at the same page, they'll also see the message pop up! So two people who are talking to each other on different computers can see the messages pop up.

Check out the [action-cable-setup](https://github.com/samanthamorco/action-cable-chat-example/tree/action-cable-setup) branch for how I set my code up.

## What is Action Cable?

Action Cable is a new feature in Rails 5. It integrates something called WebSockets with Rails. WebSockets is basically bidirectional communication between your browser and the server. Essentially, Action Cable allows for real time features to be written in Rails.  It's a full-stack offering that provides both a client-side JavaScript framework and a server-side Ruby framework. It follows the Publisher/Subscriber paradigm. We’re going to create a system where a user can subscribe to the feature which will then publish their message.

Theoretically you can create a chat app without using Action Cable at all. The cool thing about this is that when you send your message, everyone who is looking at that chatroom will see that message without a page refresh (even if they're on different computers). This isn't possible with JS or Vue (you'd have to refresh the page if you weren't the sender).

## Steps
This is assuming you have the basic chatroom set up already. Please check the code in the master branch for setup. These steps are just for getting Action Cable working.

Sidenote: Make sure jQuery is installed. We'll be using that later on.

1. Add `<%= action_cable_meta_tag %>` in your head tag in your `application.html.erb` file.
2. In the messages controller add the following code in the create action after the message has been saved:
```
ActionCable.server.broadcast 'messages',
  message: message.content,
  user: message.user.email
head :ok
```
3. Change message into a partial. This way the ActionCable JS code can push straight into the partial. It seems to not work if it's not in a partial.
4. `rails g channel messages` to generate channels for ActionCable to link to.
5. Add `stream_from 'messages'` to the subscribed method in the messages_channel.rb

This sets up Action Cable to open up a "channel" that we can send data along. Basically, we want to send data along every time a new message is sent. Let's set that up in the controller.

6. Here is what my Message controller looks like:
```
class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    message = Message.new(content: params[:content], user: current_user, room_id: params[:room_id])
    if message.save
      ActionCable.server.broadcast 'messages',
        room_id: message.room_id,
        message: message.content,
        user: message.user.email
      head :ok
    end
  end
end
```

Basically, you save the message as normal, and after you save it, you "broadcast" that with Action Cable. The keys, like `room_id`, `message`, and `user` can be whatever you want, but I'll leave them like this to make it clear what they are. We'll be using these in just a bit.


7. When you generated the channel, this should have also created a `messages.coffee` file for you in `assets/javascripts/channels`. If it's a coffee file, change it to a js file (if it's already a js file, leave as is). Put the following code in there:
```
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
```
Basically here, we're receiving the information from Action Cable broadcasting it. The variable `data` holds everything you broadcasted from the controller. Here we're going to append a div with an id "messages-#", # being the chatroom id, and show the messages if there weren't any before.

The render message function pushes the actual message onto the page.

Now, we haven't touched the HTML yet. Let's get to that.

8. The important part here is the show page of a chatroom, which is a chatroom which shows the messages for that chatroom. Mine looks like this:
```
<h1><%= @room.title %></h1>
<% if @room.messages.any? %>
  <div id="messages-<%= @room.id %>">
    <%= render partial: 'messages/message', collection: @room.messages%>
  </div>
<% else %>
  <div class="hidden" id="messages-<%= @room.id %>">
  </div>
<% end %>
<%= form_tag room_messages_path(@room), remote: true, method: :post do %>
  <div>
    <%= text_area_tag :content, "", class: "form-control", data: { textarea: "message" }%>
  </div>
  <div><input type="submit" value="Submit message"></div>
<% end %>
```

Let's break this down, starting with the form submission:

```
<%= form_tag room_messages_path(@room), remote: true, method: :post do %>
  <div>
    <%= text_area_tag :content, "", class: "form-control", data: { textarea: "message" }%>
  </div>
  <div><input type="submit" value="Submit message"></div>
<% end %>
```

First we're creating a form that's going to hit our messages controller's create action. The `remote: true` part makes sure that a page redirect is not triggered.

The data is for making sure that a user can just hit enter and it'll submit their message. We'll get back to that later though.

Next, let's look at the part that's actually showing the messages:
```
<% if @room.messages.any? %>
  <div id="messages-<%= @room.id %>">
    <%= render partial: 'messages/message', collection: @room.messages%>
  </div>
<% else %>
  <div class="hidden" id="messages-<%= @room.id %>">
  </div>
<% end %>
```
In the if condition, we're rendering a partial that shows each individual message. You can read more about what collection does [here](http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials).

In the else condition, we're just hiding the the messages if there aren't any.

Note the ID for both of those divs is the same. `@room` is a variable set in the chatroom controller, which is just that specific chatroom. We do this to make sure the IDs are unique for each chatroom page. If we don't do this, then messages may show up in chatrooms they don't belong to!!

Now, let's set up the partial. I created a file called `_messages.html.erb` in the messages folder.

It looks like this:
```
<div>
  <h3><%= message.user.email %>:</h3>
  <p><%= message.content %></p>
</div>
```
Pretty standard partial. Again, read the Rails docs for more information about partials.

9. Now this is looking pretty good! However, people still have to actually hit the submit button to send their message. It would be nice if they could just hit enter and it would send their message along.

Add this code into a Javascript file:
```
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
```

This will basically watch the typing going on in the textarea field with the class of "form control", and if the enter key is pressed, it will send their message and clear the input box.