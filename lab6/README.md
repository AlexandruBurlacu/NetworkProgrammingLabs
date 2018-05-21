# Laboratory work 6 steps of solving
## Step 1 : Identification of packets.
To identify the packets we will use WireShark and the application that was provided. 

Open wireshark and select the interface we will be tracking, the interface I use is vEthernet (windows). 
To make work easier close the browser and all applications that are using internet. 
Open the application and select username and hit enter.

Now we need to filter our packets, to do this type `udp` in filter box. 
The perfect scenario is that you should have one UDP paket. 
If you have multiple packets and can't find the one you are searcing we will cheat a little and filter it by port. 
The application is using the 42424 port as receiving port for all packets, to filter by port use `tcp.port == 42424`. The following screen is our wireshark window with the packet sent by application.

![ScreenShot](http://i.imgur.com/7nL1yYO.png)

All other packets will be sent to exactly this port, so you can keep this configuration to track all packets.

## Step 2 : Identification of received data.
Before we go any further, if you didn't try to send messages and see what are the packets, then you should know that there are 2 types of structures for packets.

### First structure. (Used when a new user is registered)
Lets take a look at our packet we received.
![ScreenShot](https://i.imgur.com/Kjx589u.png)

What the fuck is this? You may ask. Don't worry this is just the packet content. On the left we have hexadecimal representation and on the right we have ascii for those hexes. The data looks like a horse took a crap in the packet, however this is just a Base64 encoded string. 

If you are on windows and have problems copying ascii text, then do the following : Copy -> ... as Hex Stream (make sure you copy only the data content not content of all packet.), open a hex to string converter, I used [Hex decoder](http://string-functions.com/hex-string.aspx) and convert it to a string. All the others platforms can copy the ascii without any problems.

Now let's decode our Base64 string. To decode I used [Base64 decoder](https://www.base64decode.org/) .

Our final result looks like this :  `1526490703519|b0662059-d19d-4943-b4c9-b376b1e4f6be|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAidmFzZW9rIn0=`

Ok, this is more readable but not by much. So this structure contains multiple values separated by |. The structure is members are :
1. `1526490703519` - Time from miliseconds, this current value is Wed May 16 2018 20:11:43 GMT+0300.
2. `b0662059-d19d-4943-b4c9-b376b1e4f6be` - UUID, this is a unique identifier of the created user. This UUID will be used later so it is important to understand what it is for.
3. `:all` - This field is a filter to tell the program that the packet he received needs to be broadcasted. Why you may ask? This is to make sure that all users that are connected receive the new user name.
4. `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAidmFzZW9rIn0=` - This looks familiar? Yes indeed it is another Base64 ecoded string. The result after decoding is `{:type :online, :username "vaseok"}`.


If you have multiple users and register, you will observe that multiple packets are sent, this happens because after receiving this packet, the app broadcasts packets to all users that are active.

Now let's try to create our own packet and see if it will work to fool the system that a new user was created.
To send packets I use `Packet Sender`.

1. Create our name. The name for new user will be Sosika. So we create `{:type :online, :username "Sosika"}`.
2. Now we need to encode it to Base64. The result will be `ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiU29zaWthIn0=`.
3. We need to rebuild the previous packet structure now. The previous packet structure was `1526490703519|b0662059-d19d-4943-b4c9-b376b1e4f6be|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAidmFzZW9rIn0=`
4. We leave the time, since we are not interested for now. We change our UUID so that it will be different from the first one, all UUID should be unique for each user. Our new UUID will be `b1662059-d19d-4943-b4c9-b376b1e4f6be` .
5. We have all the components for our new packet : `1526490703519|b1662059-d19d-4943-b4c9-b376b1e4f6be|:all|ezp0eXBlIDpvbmxpbmUsIDp1c2VybmFtZSAiU29zaWthIn0=`
6. Now we need to encode the contents to Base64: `MTUyNjQ5MDcwMzUxOXxiMTY2MjA1OS1kMTlkLTQ5NDMtYjRjOS1iMzc2YjFlNGY2YmV8OmFsbHxlenAwZVhCbElEcHZibXhwYm1Vc0lEcDFjMlZ5Ym1GdFpTQWlVMjl6YVd0aEluMD0=`
7. We can send the packet now. More of the data that you need can be found in wireshark by looking at the packet, such as : destination ip, port.

![ScreenShot](https://i.imgur.com/mGha6JL.png)

We should have a new packet in wireshark and a new user named Sosiska.

![ScreenShot](https://i.imgur.com/ZYJc2Kw.png)

### Second structure. (User sends a message)
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

1. Encoding the text message : `{:type :chat, :txt "eheh boi"}` to Base64 : `ezp0eXBlIDpjaGF0LCA6dHh0ICJlaGVoIGJvaSJ9`
2. Getting UUID of our fake user : `b1662059-d19d-4943-b4c9-b376b1e4f6be`
3. Finding a UUID for to who send the message, we will use the UUID of the first user we created : `b0662059-d19d-4943-b4c9-b376b1e4f6be`
4. Making our message : `1526494592670|b1662059-d19d-4943-b4c9-b376b1e4f6be|b0662059-d19d-4943-b4c9-b376b1e4f6be|ezp0eXBlIDpjaGF0LCA6dHh0ICJlaGVoIGJvaSJ9`
5. Econding it to Base64 : `YDE1MjY0OTQ1OTI2NzB8YjE2NjIwNTktZDE5ZC00OTQzLWI0YzktYjM3NmIxZTRmNmJlfGIwNjYyMDU5LWQxOWQtNDk0My1iNGM5LWIzNzZiMWU0ZjZiZXxlenAwZVhCbElEcGphR0YwTENBNmRIaDBJQ0psYUdWb0lHSnZhU0o5YA==`
6. Sending it using Packet Sender.

If you followed all the steps correctly you should have received the message inside the app.
![ScreenShot](https://i.imgur.com/C6a1SR9.png)
