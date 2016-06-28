#!/bin/sh

curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh


/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-elasticsearch

#/etc/init.d/td-agent start



tee /etc/td-agent/td-agent.conf <<-EOF
<source>
  type forward
  port 24224
</source>

<match *.*>
  type stdout
</match>
EOF
