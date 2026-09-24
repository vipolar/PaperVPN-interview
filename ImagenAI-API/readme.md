# AI image generation studio API (unfinished)

So, this one is actually a good showcase of **python** usage for guided automation.

The idea was for this to be an API that manages AI image generation services, utilities, models, etc...  
By that I mean pulling, installing everything including the dependencies, (sym)linking models to the appropiate directories (every service works differently,) and much more.  
It would've been a better idea had the client thought through what they were actually trying to do here... They asked me to make a site for their contractors to go on, get a server with a GPU running on the selected provider (there were multiple, all with their own broken APIs) and get whatever they needed to run running easily.  
The output of a running process would be streamed to the frontend (I haven't included that here cause it's irrelevant to our needs but it was actually working nicely) and give the contractors the ability to work with these tools as if they had them installed locally.  
I guess the idea was admirable but the business model was not fully thought through... They asked to include all utilities and services (some of them long deprecated, even for the time this was in the works) because some of the contractors might want to use them. Also wanted to make it extensible and "completely their own," which I understand but does "small-to-mid-sized" studio need this? I told them that it was too much unless they were planning to compete with the existing, established solutions like [runpod](https://www.runpod.io/) or [mimicPC](https://www.mimicpc.com/) who offered a lot of the same features albeit with some limitations, but still...  
Long story short, I began developing this and the frontend (for which they promised to hire a dedicated designer later on,) at some point they realized that it was costing them too much and whatever they wanted from this being "completely their own" didn't really make much sense, and their contractors were actually getting by on runpod, mimicPC, and whatever else, nicely... so they scraped it and honestly for the better.  
But it did let me do some interesting stuff while I was working on it...

## So, let's get this going!

Inside [AI-Repos](./AI-Repos/) directory there are tons of ```.metadata.json``` files describing services, utilities, models, etc., (see [AI-Labs/Kohya_ss](./AI-Repos/AI-Labs/Kohya_ss/.metadata.json) for an example of a service or [AI-Models/Flux.1-dev](./AI-Repos/AI-Models/FLUX.1-dev/.metadata.json) for an example of a model) and the idea is for them to be hotswappable, modifiable, extendable... You can add a ```.metadata.json``` of your own, tell the API that you've done so and it would become available for you right away.  
On startup the backend crawls through the [AI-Repos](./AI-Repos/) (set by ```STUDIO_BASE_DIR``` env variable) directory and finds all ```.metadata.json``` files available, parses them, and creates the master dictionary (representative of the ```STUDIO_BASE_DIR``` directory structure) that is cached in memory, from where the services, utilities, models, etc., can be called by the frontend.

So, let's discuss ```.metadata.json``` file of an example service (e.g. [AI-Labs/Kohya_ss](./AI-Repos/AI-Labs/Kohya_ss/.metadata.json)) to better understand what is happpening inside it.  
It contains, id, commands (install, update, uninstall, launch,) all kinds of descriptions, special flags, cli arguments, env variables, and flags for the commands mentioned above.  
By design a service can have multiple, isolated from each other, protected instances installed (for each user, or multiple instances for one user, or any combination...) but more importantly, the services can block each other while they are running, and depending on what command is running it can also block other commands of the same service/instance from running. See:
- "blockOtherServices": ["some_service", {"some_other_service": ["install", "uninstall"]}]
- "blockOtherCommands": ["install", "update", "launch"]
- "allowMultipleInstances": false

As for the how the commands do what they say they do... easy, it can be a literal command, like ```"git clone --recursive https://github.com/bmaltais/kohya_ss.git ${instance_uuid}"``` or a whole script that does the actual installation, launching, or anything else...  
And for the ```${instance_uuid}``` in there, and ```${instances}```, ```${installed}```, etc. in the ```.metadata.json``` files, all of these special key phrases are recognised by the associated parser and depending on the context can block the command's execution, request/expect arbitrary input, provide/generate arbitrary data, etc... for example ```${instances}``` in this case will work as a placeholder for a list of installed instances of the service available to the requesting user.

Now, ```.metadata.json``` files for the models (e.g. [AI-Models/Flux.1-dev](./AI-Repos/AI-Models/FLUX.1-dev/.metadata.json)) are much easier. They specify what to download and from where and where to (sym)link them to depending on the service you intend to use them with.

As for the ```.metadata.json``` files for the utilities??? I've told you, this is unfinished, there's nothing special going on there...  
Same goes for most of the actual scripts, although [FileBrowser utility](./AI-Repos/FileBrowser/.service.sh) does have a working one (tiny but it works...)  

### But! There's more!

I've included this repo as a demonstration of my **python proficiency**, it contains a very intricate metadata parser with some very novel ideas!  
By passing ```extract_keys``` and ```exclude_keys``` you can shape the object you get back as you want. Included [test cases](./tests/test_deserialize_metadata.py) are pretty good at showing how it works but I'll go over it again here:
- If ```extract_keys``` are specified you'll get only the keys specified.
- If ```exclude_keys``` are specified you'll get everything except for the keys specified.
- If both ```extract_keys``` and ```exclude_keys``` are specified you'll get only the keys in the ```extract_keys``` with the ```exclude_keys``` excluded from them.
- If the same key is specified twice on the same level and it is present twice in the dictionary on the same level (allowed by JSON format,) you'll get both of them otherwise you'll get only the first one (works on any number of keys...)
- If a chain of keys is specified in ```extract_keys``` (e.g.: ```some_key.some_nested_key.some_deeply_nested_key```) you'll get specifically ```some_key``` -> ```some_nested_key``` -> ```some_deeply_nested_key``` (same goes for the ```exclude_keys```.)
- If the dictionary for some reason includes a key ```some_key.some_nested_key.some_deeply_nested_key``` (again, allowed by the unholy abomination that is JSON) and you specify it, parser will match it first before going through the nested keys so you'll get ```some_key.some_nested_key.some_deeply_nested_key``` and you'll have to live with what you have done!!!
- If you specify a key like ```.some_key``` and it is found, fine, but if for some reason you have a ```.``` key on this level and it has a ```some_key``` nested within it, I hate you, but by GOD, you WILL get that key!!!
- If you specify a key like ```...``` and you have ```.``` -> ```.``` going on in the dictiory, you'll get it... I'm not asking why you did that... I'm not judging... but, aren't you afraid of some higher power out there?
- Everything mentioned above works on any and all levels of nesting.

Oh, but if you thought I was done... let me tell you about the ***wild cards*** and the ***jokers*** as I lovingly call them!
- If ```extract_keys``` has ```*``` specified, every key on that level will be included (```*``` does not have to be a surface level key, it works the same way no matter how deep it is nested e.g.: ```some_key.some_nested_key.*``` will get you ```some_key``` -> ```some_nested_key``` -> ```(every key here)```.)
- If ```extract_keys``` has ```*.some_nested_key``` specified, every ```some_nested_key``` that is a child of a key on this level will be included.
- If ```extract_keys``` has ```*``` and for some god forsaken reason you actually have a ```*``` key present in the dictionary, parser will match it first and you'll get it. As long as the symbols in the key have an exact match they will get you the exact match, after that you'll get the rest of the functionality (like the wild cards.)
- If ```extract_keys``` has ```**``` specified then you'll get everything on that level and everything nested within (```**``` does not have to be a surface level key, it works the same way no matter how deep it is nested e.g.: ```some_key.some_nested_key.**``` will get you ```some_key``` -> ```some_nested_key``` -> ```(everything here and what is nested within)```.)
- If ```extract_keys``` has ```**.some_nested_key```  specified, you'll get every ```some_nested_key``` no matter where they are nested and how deep starting from the level the joker is encountered (meaning you can do ```some_key.some_nested_key.**.some_deeply_nested_key``` if you want to.)
- If ```exclude_keys``` has either or both of the ```*``` and ```**``` specified, they will work all the same but for exclusion of the specified keys as expected.
- Exact symbol matching works the same for all special symbols as mentioned above, if whatever you pass is present in the dictionary as a whole you'll get it, if not then special symbols will do their magic.

And of course...
- If ```extract_strict``` is set to ```true``` and there is no match in the dictionary for the key specified in the ```extract_keys``` argument error will be thrown, otherwise it will be silently skipped.
- If ```exclude_strict``` is set to ```true``` and there is no match in the dictionary for the key specified in the ```exclude_keys``` argument error will be thrown, otherwise it will be silently skipped.
- The above rules do not apply to *wild cards* and the *jokers*, obviously.

Honestly, I'm pretty sure I'm forgetting something here, there's probably some defined behavior I haven't described here but then again, this is an old project I dug up to put it on display for you to check out.

## So, what's the takeaway?

Well, this is a good example of "thinking in systems." I could've done a lot of this in a series of patch-works, were I take each service, model, utility, whatever, and hardcode every one of them... then when the client would need to add something to the list, they would have to call me again to do so. While it could theoretically mean a source of recurring revenue, I honestly think it wouldn't be worth the grueling, mind-numbing work that comes with it.

I believe that careful planning, accounting for the forseeable contingencies, and building a system, while slower to get the ball rolling, does make everyone else's lives easier down the road. Systems, when thought through, are resilient, extensible, and easy to understand for and walk through (although, good documentation does help.)