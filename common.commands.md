---
id: common commands
aliases: []
tags:
  - commands
---


```bash Formatting Jumpmind json logs
./format-logs.sh out | tee out.json
jq '. | select(.level == "ERROR") | .stack_trace' out.json |  sed 's/\\n/\n/g; s/\\t/\t/g'
```
```shell Find and replace file names
find . -type f -iname "*some file" -execdir mv {} "new file" \;
```
```shell Find and replace strings in place
grep -rl "old_string" . | xargs sed -i '' 's/old_string/new_string/g'
```
```shell Delete old local branches
 git b | grep -v "main" | awk '{print $1}' | xargs git bd
```

### grafana logs
```
{namespace="", container=""} |= `` | json | line_format `{{.message}}`
```

### Tmux
- switch sessions: bind key + s
- move window to specific spot: swap-window -t index
- swap window with previous spot: swap-window -t -index
- swap window with next spot: swap-window -t +index
- swap specific windows: swap-window -s [source index] -t [destination index]
