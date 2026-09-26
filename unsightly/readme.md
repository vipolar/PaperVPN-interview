# The good, the bad, and the unsightly!

This was one of the first things ever I got paid for to make!  
I was a sophomore student at my university at that time (probably 19 years old,) studying international relations... I still can't wrap my head around how I ended up working in the "IT department" of the university but what the "IT department" actually was is even more mind blowing - just 3 students and a clueless manager, doing everything from troubleshooting lecture equipment, handling security cameras, physical servers, networking, maintaining the jankiest of sites (2 of them actually,) and sending students their passwords to the portal when they would forget it (because they were stored in a .txt file unencrypted and unhashed.)

At that time I was no stranger to programming and scripting, especially on windows machines (everything in the university ran on windows.) I would write some batch scripts so that the other "IT department staffers" wouldn't have to install every single piece of software on the machines in classrooms manually when they would need to be reset (it happened more than it ever should've if the universe were even a bit fairer but, well...)

I did a lot of stupid stuff there, working on windows machines for example... BUT!!!  
I also got paid very little to do so...

### So, what's the linux bash script doing here?

Well, I was already experimenting with linux (both for personal and server use) for some time at that point but actually having to do stuff on windows every day just drove me over the edge! I was trying to shove linux down the throats of the university and the "IT department" telling them how much easier it would make their lives (and mine too) if they would allow me to run a linux server and their internal portal (the one with unencrypted and unhashed passwords) to it.

Of course I took the security incredibly seriously, keeping the server constantly up-to-date with ubuntus ```unattended-upgr```, and that's where the headache started!  
For some reason, every time it would update by itself, it would try to reboot and hang the server (to this day I have no idea why...) So I made a (very POSIX incompliant) [bash script](./reboot-check.sh) to detect if the system was in need of a reboot and reboot it... and for a good measure I also wrote [another one to reboot the server once a day](./reboot-daily.sh) at 4AM (thank god I had enough brains to not hardcode that too in a script and made it a cron job) just to be safe!

Of course none of this reached production (I didn't even know what that would mean) but I still adamantly hold the beilief that it was because they were afraid of linux and not because it was just bad!

### But it does get better...

A lot has changed since those days... I've started daily driving [linux](https://i.kym-cdn.com/photos/images/newsfeed/002/243/370/6d1.jpg) for one (been doing it for 10 years now I think...) have broken and built many servers, and have tried my hand at almost anything I could reach.

Since those times I've gotten much better... it was a lot of trial and error, a lot of different projects (both paid and personal,) a lot of experiments through which I developed a bit of a sense of what's better, and a bit of a taste too. I hope you've seen some of it already in this repo or in some other repos of mine on github...

## So, what's the takeaway?
[![The horror](https://img.youtube.com/vi/n7rwY9cqabc/0.jpg)](https://www.youtube.com/watch?v=n7rwY9cqabc)