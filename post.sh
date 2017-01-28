#!/bin/bash

DATE=`date +%Y-%m-%d`
FILENAME="_posts/${DATE}-${1}.md"

cat <<EOL > ${FILENAME}
---
title: 
layout: post
---

EOL

exec nvim ${FILENAME}
