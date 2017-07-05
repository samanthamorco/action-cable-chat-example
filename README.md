# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
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
6. 