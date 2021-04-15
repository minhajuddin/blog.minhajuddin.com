title: How to show Raspberry Pi temperatures in your Datadog dashboard
date: 2021-04-15 10:38:57
tags:
- raspberry pi
- cluster
- datadog
- temperature
---

So, I've set up a cluster of 4 Raspberry Pis to learn and experiment with
distributed systems.

{%asset_img pi-cluster.jpeg My Raspberry Pi Cluster %}

I also wanted to track various metrics while running the cluster, so I set up
Datadog APMs on all of them and since the pis usually run hot, I wanted to track
their temperatures for warning signs. Here is how you can send your temperature
info to Datadog.

Create 2 files, a `temp.yaml` and a `temp.py` (the names should match).

```yaml
# /etc/datadog-agent/conf.d/temp.yaml
instances: [{}]
```

```python
# /etc/datadog-agent/checks.d/temp.py

from pathlib import Path

# the following try/except block will make the custom check compatible with any Agent version
try:
    # first, try to import the base class from new versions of the Agent...
    from datadog_checks.base import AgentCheck
except ImportError:
    # ...if the above failed, the check is running in Agent version < 6.6.0
    from checks import AgentCheck

# content of the special variable __version__ will be shown in the Agent status page
__version__ = "1.0.0"

class TempCheck(AgentCheck):
    def check(self, instance):
        self.gauge(
            "custom.temperature",
            (int(Path("/sys/class/thermal/thermal_zone0/temp").read_text().strip()) / 1000),
            tags=[],
        )
```

The meat of this code is the following, where we send a `guage` metric named
`custom.temperature` and send it the temperature by reading
`/sys/class/thermal/thermal_zone0/temp` (this is how you can read the
temperature for a pi with ubuntu installed, you may have to tweak this bit for
other distros)
```python
self.gauge(
    "custom.temperature",
    (int(Path("/sys/class/thermal/thermal_zone0/temp").read_text().strip()) / 1000),
    tags=[],
)

```

That's it, you can tack other metrics in their too if you'd like to. You'll also
need to restart your datadog agent for it to start sending these metrics.

You can [read more about custom metrics in Datadog  here](https://docs.datadoghq.com/developers/metrics/agent_metrics_submission/?tab=count#tutorial)
{%asset_img dd.png Max of custom.temperature by host %}
