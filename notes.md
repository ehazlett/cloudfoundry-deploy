# Build Notes:
These are the post install configuration notes:

* In the current state, the service Redis backend doesn't have a start script, create one:
  * Create a `/etc/init/vcap-services-redis.conf` with the following:

```
description     "VCAP Services (redis)"

start on runlevel [2345]
stop on runlevel [!2345]
expect forkrespawn
exec /home/cfsystem/cloudfoundry/.deployments/vcap/deploy/redis/2.6.2/bin/redis-server /home/cfsystem/cloudfoundry/.deployments/vcap/config/services_redis.conf
```

  * Start the VCAP Services Redis instance: `sudo service vcap-services-redis start`

* Start the Cloud Controller, UAA, Router, and Health Manager:
  * `sudo cf_control start cloud_controller`
  * `sudo cf_control start uaa`
  * `sudo cf_control start router`
  * `sudo cf_control start health_manager`
* Edit `$HOME/cloudfoundry/.deployments/vcap/config/uaa.yml`:
  * Add the following under the `spring_profiles: postgresql` line:

```
uaa:
  uris: [ uaa.customdomain.com, login.customdomain.com ]
```

  * At the bottom of `uaa.yml` change the `redirect-uris` line of the `vmc` section to the following:

```
redirect-uri: http://uaa.customdomain.com/redirect/vmc,https://uaa.customdomain.com/redirect/vmc
```

** In both edits make sure to change `customdomain.com` to your domain.
  
  * Restart Cloud Controller and UAA:
    * `sudo cf_control restart cloud_controller`
    * `sudo cf_control restart uaa`

You should now be able to `vmc target`, `vmc register`, and `vmc login`.

** Note: if you don't start and edit in the exact order above, you may receive a `redirect_uri_mismatch` error from the UAA.  This occurs because the database has a different value in the `oauth_client_details` table for the vmc service.  At this time, it must match uaa.cloudfoundry.com even though it's on a custom domain.
