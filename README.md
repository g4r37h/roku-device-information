# Roku Device Information

This is a **simple device information utility** for Roku. It displays device-specific information neatly and succinctly.

It was written for use by the QA team on my current project but it might well prove useful to someone else so here it is.

## Build

Create a file called `.env` at the root of the project directory. Inside this file, declare the following environment variables and assign appropriate values:

```
ROKU_DEV_TARGET={IP_ADDRESS}
ROKU_DEV_PASSWORD={PASSWORD}
DEBUG_PORT=8888
```

In VSC, press F5 or select "Run/Start Debugging".