#!/bin/sh
#
# Jira/Confluence restart script
# Written by Tom Reeb, Coriell Institute for Medical Research

# Stop Jira service

service jira stop

# Restart Confluence

service confluence restart

# Start jira service

service jira start