#!/bin/bash
rm -rf docs/*
hugo -d docs
cp static/index.html docs
