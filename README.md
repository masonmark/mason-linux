# Mason Linux

A specific configuration of CentOS that will hopefully provide the base Linux server platform for everything I (Mason) need to do.

<blockquote>
  <pre>
    Mason Linux == CentOS + software + configuration
  </pre>
</blockquote>

Right now, all that is contemplated is automation that applies configuration and installs software, thereby transforming a virgin CentOS 7 instance (whether it be a local VM (e.g., a VMWare VM) or a remote VPS (e.g. an AWS EC2 instance)) into a full-fledged Mason Linux instance ready for battle.

Once that is done, it would be very nice to make sure all the automation is completely idempotent, so that it can apply to a virgin CentOS instance, a partially-configured instance, or an already-configured Mason Linux instance.

Someday, it would be awesome to extend this to be able to provision a Mason Linux from nothing (that is, to provision a virgin CentOS instance too if needed). But I have young kids, and only about 58 more years to live, so... who knows.

以上
