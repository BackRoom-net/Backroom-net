# Backroom-net

Decentralized file sharing network similar to the Torrent Network.

Basically where I (Noisy) want to go with this project is to-

* Create a program where a Client can share files which will be Compressed and Encrypted all in one go.
   In addition, other clients throughout the network can connect and download the files.

* The Clients will have their IP addresses secured but they will all link up to form a big network. 
   So, If one client connects to one that is connected to lots more, a Public address link can be shared.
   That brings about the possibility of a huge sharing interconnected secure file sharing network!

* Have a little fun. I'm not doing this project for no reason or to gain profit! I'm quite new to Github!
   I would love to see what other people have to say about the project and maybe even work with some people!


Please request for Collaboration!  - Ruben Rodriguez - rubenrodvideos@gmail.com

# Purebasic

This program is being developed under PureBasic 5.61 (Windows - x64)
Purebasic 5.60 Code has been fixed!!

12/1/17: RESOLVED
Purebasic 5.60 Is Not currently working correctly. Working on getting the newest version 5.62 because 
Apparently 5.60 has a libary issue with Threaded applications. Basically, You wont be able to run a thread
without Using:
```Purebasic
Thread = Createthread(@Mythread,*SomeNumber)
Debug WaitThread(Thread)
debug Thread
;Then the Thread will execute. but this takes too much time.
```
I really Want to run the thread independantly from the main thread
because Logging to the disk takes too much time.
