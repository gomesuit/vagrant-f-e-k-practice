#!/bin/sh

touch /tmp/money.json
echo '{"@timestamp":"2014-01-14", "category_name":"食費", "genre_name":"昼ご飯", "place":"社食", "comment":"", "amount":500, "from_account_name":"夫の財布"}' >> /tmp/money.json
echo '{"@timestamp":"2016-01-02", "category_name":"エンタメ", "genre_name":"書籍", "place":"技術評論社", "comment":"サーバ／インフラエンジニア養成読本 ログ収集〜可視化編", "amount":1980, "from_account_name”:"夫の財布"}' >> /tmp/money.json
echo '{"@timestamp":"2016-01-02", "category_name":"交通", "genre_name":"電車", "place":"新幹線", "comment":"帰省のため", "amount":13000, "from_account_name":"共有の財布"}' >> /tmp/money.json

tee /etc/td-agent/td-agent.conf <<-EOF
<source>
  type tail
  format json
  path /tmp/money.json
  pos_file /tmp/money.json.pos
  tag zaim.money
</source>

<match zaim.money>
  type elasticsearch
  host 127.0.0.1
  port 9200
  index_name zaim-money
</match>
EOF

/etc/init.d/td-agent restart

curl -XPUT http://localhost:9200/zaim-money -d '
{
  "mappings": {
    "fluentd": {
      "properties": {
        "@timestamp": {
          "type": "date",
          "format": "strict_date_optional_time||epoch_millis"
        },
        "amount": {
          "type": "long"
        },
        "category_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "comment": {
          "type": "string"
        },
        "from_account_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "genre_name": {
          "type": "string",
          "index": "not_analyzed"
        },
        "place": {
          "type": "string",
          "index": "not_analyzed"
        }
      }
    }
  }
}
'

#tail /var/log/td-agent/td-agent.log
