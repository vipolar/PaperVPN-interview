# AWS API Gateway Demo

Well... I wanted to share something that was actually in production but how do you do that without making sensitive data public? More than that, how do you show a setup of something that is usually done incrementally on the need basis? So, I made a small (not really) demo. My focus here is of course on the AWS services rather than the Angular frontend I just shoved in there for a quick visual demonstration, so don't judge me on how it looks, I'm judging myself on it already as it is!

Unfortunatelly, since this is a rush job, a lot of the stuff in the demo is hardcoded in and the script is a bit too much on the eyes... but it works! My goal was to make something that you can run locally (yes, I mean you can clone this repo and run it) and get things running in a minute.

It's nothing special, but sometimes that's all you need...

### So, let's get to it!

First, let's start with [lambda.py](./lambda.py). It's an incredibly simple "api" (it deserves to be in quotes!) it has absolutely no protection, no parsing of anything, no validation... it's just something to give you a response depending on which route you hit it from ```/guest```, ```/user```, and ```/admin``` and reject everything else with an ```404``` or ```405``` if it's hit with anything other than a ```GET``` request. Simple as that.  
There's another lambda too but let's keep that one for later...

Now, [setup.sh](./setup.sh) is where the magic happens. It's basically a chain of AWS CLI (v2) commands that sets up API Gateway (routes, integration, authorizer, stage, etc.) Of course, by itself that is nothing special, but when coupled with Cognito (user pool, resources server, groups, and groups based scopes,) we are already onto something worth talking about.

API Gateway has 3 routes, ```/guest``` which is accessible to anyone, ```/user``` that is for users in the group, you guessed it "users", requiring a valid JWT issued by Cognito, and ```/admin``` for admins, also requiring JWT. Aside from that, there are ```GET /{proxy+}"```, ```PUT /{proxy+}"```, ```POST /{proxy+}"```, ```DELETE /{proxy+}"``` requiring JWT with "admin" scope so crawlers don't get to know what our "api" actually looks like and more importantly, so that our "api" doesn't get hammered with all the undefined route requests.  
I didn't do ```ANY /{proxy+}"``` for the above because that would also block ```OPTIONS``` requests which are needed for **CORS** if you want browser support (which, because of the Angular client, we do need.)

So, how do we make Cognito aware of the scope requirements of the resources server? Well, that's where [cognito.py](./cognito.py) lambda comes in. It is invoked on ```PreTokenGeneration``` and manipulates the access token so that it contains only the scopes appropriate for the group user belongs to, giving us the "groups based scopes" I mentioned above.

### Anything else?

Other than the above... there's IAM roles, policies, permissions, etc. and everything is done through that script (even the compression of the lambdas to zip.) It is an extensive script that in the end writes the ```.env``` file for the Angular client with all of the URIs and IDs needed for it to actually work. All you need to get this whole thing going is **7z**, **AWS CLI (v2)**, and **Node.js (20+)** for the Angular client.

If you decide to give it a try, you'll have to modify the [setup.sh](./setup.sh)'s ```AWS_PROFILE``` and ```AWS_REGION``` to something that is applicable to you and you are good to go!

## So, what's the takeaway?

Well... it's a good starter script to put in the "ground floor" so to speak. In the production environment it would require much more of course... things like rate limiting, usage quotas, more extensive policies, more extensive Lambdas, you name it. But as a small showcase, this should work. It's a fully automatized script to set up API Gateway, Lambdas, IAM, Cognito, and even a frontend to connect to the "api" (I'm gonna keep referring to it with quotes til the end of times!) but yeah, making it all a bit more readable wouldn't have hurt no one though, I guess... but well, it is what it is!