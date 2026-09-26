# Redacted, redacted, redacted...

This is actually deployed in production right now and the only part of it that I can show is the old (very old) dev env server setup for the developers to quickly get started on a clone server of their own (replicability and the ease of setup was a huge requirement.)  
Again, I had to redact even the name of the project since this repo is public and I don't want to accidentaly reveal anything to a random crawler that stumbles upon it, or even worse get sued for having it publically available.  
The actual repo of course doesn't look like this now but this will still work to showcase some small scripts that do the actual work.  
So, with all that out of the way...

### It's all really simple!

The [ubuntu-server-setup](./ubuntu-server-setup/) directory doesn't really have anything too interesting going on for it, it's just a bunch of tiny setup scripts to get the new server going: user, firewall ([blocking docker from exposing ports on its own by bypassing ufw](./ubuntu-server-setup/ufw/ufw-docker.rule)), fail2ban, [sshd configuration (hardened)](./ubuntu-server-setup/sshd/10-redacted-base.conf), docker, java17, node, etc.

On the other hand [developer-environment](./developer-environment/) directory does have a thing or two worth mentioning.  
Script [docker-build.sh](./developer-environment/docker-build.sh) does more than what it pretends to do by name alone. It heavily relies on ```envsubst``` utility to have derived env variables AND generate static configuration files on the fly from the provided templates in the [resources](./developer-environment/resources/) directory.  
Script [docker-cleanup.sh](./developer-environment/docker-cleanup.sh) provides couple of options for cleaning up a broken developer environment (depending on the severity) to ease a developers life a little.
And lastly there's a [docker-compose.yml](./developer-environment/docker-compose.yml) file which is pretty self-explanatory.

### Isn't this a bit TOO simple? Why would you even include this in the showcase?

Well, yeah, it's quite a simple setup BUT it does exactly what is required of it. It is lean, readable, modular... any developer coming to it can understand everything going on inside, and in the end of the day, isn't that what we all want?

Other than the above, [blocking docker from exposing ports on its own by bypassing ufw](./ubuntu-server-setup/ufw/ufw-docker.rule) is nothing to scoff at either! It's a simple solution to an often overlooked, giant, gaping-hole-of-a-problem that kinda shouldn't exist in the first place at all (but it does and has for a very long time.)

And of course, [sshd configuration](./ubuntu-server-setup/sshd/10-redacted-base.conf) for hardening the server security just a little bit more... we're talking everything from disabling password access, forwarding, changing ssh port, etc... I do remember this causing a lockout or two cause people would forget to add their public ssh keys before logging out or rebooting the server.

## So, what's the takeaway?

well... don't overcomplicate. If it works for what is required of it, keep it simple and leave it alone.

That said, some things could be improved here, for example the configuration files in the [ubuntu-server-setup](./ubuntu-server-setup/) directory (sshd config and ufw config) could be symlinked instead of doing a hard copy, guardrails can be implemented to prevent lockouts due to sshd config changes, etc.

But the important point still stands: lean, readable, modular.  
Keeping it simple, when possible...