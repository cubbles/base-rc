# cubbles-docker-utils
A set of utils, supporting core-developers to control a local docker-vm.

### Usage
1. Clone the Repo
2. Open your git-bash and `cd` into the root directory
  
  
  Basically you need to provide a .conf -file (`etc/xyz.conf`) AND 1..n commands (`lib/.../command-file.sh`)

```bash
    # Usage instructions
    $ ./bin/run.sh
    
    # Example:
    $ ./bin/run.sh etc/base-local.conf lib/base/run.sh
```
    
### Configuration
The default configuration is provided at "`etc/default/default.conf`".
Put your custom configurations into the "`etc`" directory. Any `.conf` files there are ignored by git.  

Some basic configuration files are prepared at "`etc/`":

* `base-dev.conf`: This is for developers of the Base itself. It provides configuration options to mount a local directory into the docker-vm.
* `base-local.conf`: Use this to setup and run a Cubbles Base locally. The configuration provides a Base -version (`CUBX_ENV_BASE_TAG`) used by the `lib/base/*.sh` commands.
* `sphinx.conf`: This is for developers of the Cubbles documentation published at <https://cubbles.readthedocs.io>.  It provides configuration options to mount a local directory into the docker-vm.

Want to setup some individual configs? Just copy one of the existing files, adapt it to your needs and use it. 