# Laboratory 6 - Reverse engineering an IM client

### Step 1 : Identification of packets.
Before anything, we need to install Wireshark, which will be used to capture and analyze packets sent by the application that was provided. All we know for now is that the app uses UDP and that the messages are "lightly encrypted".

We are opening Wireshark as superuser and selecting the interface we will be tracking, in our case it is `wlp3s` (Linux/Ubuntu). 
To make work easier we close the browser and all applications that are using internet, and especially UDP protocol (Bye, bye Skype).
We open the provided application, select username and hit enter.

Now we need to filter our packets, to do this type `udp` in filter box. 
Note that it's better to open the Wireshark before launching the app, so that we can track any network activity of it.
And so, we can see a packet sent when creating a user. Also we see the port number, 42424. Let's use it to keep our Wireshark window clean, by setting `udp.port == 42424` in the filter bar.

All other packets will be sent to exactly this port, so you can keep this configuration to track all packets.

### Step 2 : Identification of received data.
Before we go any further, if you didn't try to send messages and see what are the packets, then you should know that there are 2 types of structures for the packets.

### Packet Type 1. (Used when a new user is registered)

The data in the captured datagram contains some nasty characters, nothing clear. As you remember, the data is "lightly encrypted". Thanks to my groupmates, we found out that it is actually Base64 encoded. After decoding, we get the following data: `1526915893564|9f989dcf-7d5b-4ff7-8607-803e511e9ea7|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiYWxleCJ9`

Now some components are distinguishable. The protocol structure contains multiple values separated by `|`.
1. `1526915893564` - The timestamp/UNIX time in miliseconds.
2. `9f989dcf-7d5b-4ff7-8607-803e511e9ea7` - UUID, a unique identifier of the created user. This UUID will be used later to send messages.
3. `:all` - This field is a filter to tell the program that the packet it received needs to be broadcasted. This is to make sure that all users that are connected receive the new user name.
4. `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiYWxleCJ9` - This segement is also Base64 encoded. The result after decoding is `{:type :online, :username \"Jorik\"}`.

Having multiple users, you will observe that multiple packets are sent when registering a new user, this happens because the app broadcasts packets to all users that are active.

We try to create our own packet and see if it will work.
To send packets I use `bash`, namely a command of the form `echo -n <encoded message> > /dev/udp/230.185.192.108/42424`.

1. Create our name. The name for new user will be `notagainalex`. So we create `{:type :online, :username \"notagainalex\"}`.
2. Now we need to encode it to Base64. The result will be `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAibm90YWdhaW5hbGV4In0=`.
3. We need to rebuild the previous packet structure now. The previous packet structure was `1526915893564|b0662059-d19d-4943-b4c9-b376b1e4f6be|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAibm90YWdhaW5hbGV4In0=`
4. We leave the time, since we are not interested for now. We change our UUID so that it will be different from the first one, all UUID should be unique for each user. Our new UUID will be `b1662059-d19d-4943-b4c9-b376b1e4f6be` .
5. We have all the components for our new packet : `1526915893564|b1662059-d19d-4943-b4c9-b376b1e4f6be|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAibm90YWdhaW5hbGV4In0=`
6. Now we need to encode the contents to Base64: `MTUyNjkxNTg5MzU2NHw5Zjk4OWRjZi03ZDViLTRmZjctODYwNy04MDNlNTExZTllYTd8OmFsbHxlenAwZVhCbElEcHZibXhwYm1Vc0lEcDFjMlZ5Ym1GdFpTQWlibTkwWVdkaGFXNWhiR1Y0SW4wPQ==`
7. We can send the packet now. More of the data that you need can be found in Wireshark by looking at the packet, such as : destination ip, port.

We should have a new packet in Wireshark and a new user named Sosiska.

### Packet Type 2. (User sends a message)
So basically we have mutiple users. Now we need to see what happens when a user sends a message. We send a message and we can observe that there are 2 UDP packets sent. This happens because one message is the message to a user and the second is the response from the user that he received the message. Let's take a look at the content of those packets. (Make sure you send the message with a user created using the application, because you will not see the second packet.)

#### First packet.(Sent message)
After decoding the first packet with the steps from previous example we have : `1526494592670|b0662059-d19d-4943-b4c9-b376b1e4f6be|b1662059-d19d-4943-b4c9-b376b1e4f6be|ezp0eXBlIDpjaGF0LCA6dHh0ICJoZWxsbyJ9` and last decoded is `{:type :chat, :txt "hello"}` In this case the structure is : 

`1526494592670` - date in milliseconds.

`b0662059-d19d-4943-b4c9-b376b1e4f6be` - the sender UUID.

`b1662059-d19d-4943-b4c9-b376b1e4f6be` - the receiver UUID.

`ezp0eXBlIDpjaGF0LCA6dHh0ICJoZWxsbyJ9` - message.

#### Second packet.(Acnowledge)
We decode the second packet and we get : `1526494592670|b1662059-d19d-4943-b4c9-b376b1e4f6be|b0662059-d19d-4943-b4c9-b376b1e4f6be|ezp0eXBlIDpkZWxpdmVyZWR9`

Basically we have the same message structure the only difference is the content the last field that when decoded is `{:type :delivered}`

Now that we understood how this shiet works, let's send a message from our fake created user to a user that uses the application. 

1. Encoding the text message : `{:type :chat, :txt "sup?"}` to Base64 : `ezp0eXBlIDpjaGF0LCA6dHh0ICJlaGVoIGJvaSJ9`
2. Getting UUID of our fake user : `b1662059-d19d-4943-b4c9-b376b1e4f6be`
3. Finding a UUID for to who send the message, we will use the UUID of the first user we created : `b0662059-d19d-4943-b4c9-b376b1e4f6be`
4. Making our message : `1526494592670|b1662059-d19d-4943-b4c9-b376b1e4f6be|b0662059-d19d-4943-b4c9-b376b1e4f6be|ezp0eXBlIDpjaGF0LCA6dHh0ICJlaGVoIGJvaSJ9`
5. Econding it to Base64 : `YDE1MjY0OTQ1OTI2NzB8YjE2NjIwNTktZDE5ZC00OTQzLWI0YzktYjM3NmIxZTRmNmJlfGIwNjYyMDU5LWQxOWQtNDk0My1iNGM5LWIzNzZiMWU0ZjZiZXxlenAwZVhCbElEcGphR0YwTENBNmRIaDBJQ0psYUdWb0lHSnZhU0o5YA==`
6. Sending it using bash.

If you followed all the steps correctly you should have received the message inside the app.

## Client app in Elixir

Our client app has 2 functions, `send_msg` and `create_user`. `send_msg` takes as argument a string that is the message. `create_user` takes also a string, that is the new username and returns a string that is it's UUID.
Internally the client uses Erlang's `:gen_udp` open and send functions.

## Comments

The use of UDP for IM is not the best choice because this protocol lacks delivery, order and integrity guarantees. IMs do not require maximum throughput, so TCP would do as good, while being much more reliable.
An use case for UDP would be video or voice chat.
