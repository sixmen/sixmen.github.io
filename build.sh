#!/bin/bash
rm -rf public/*
hugo
cp static/index.html public
